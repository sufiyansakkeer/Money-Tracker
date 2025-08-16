import 'dart:developer';
import 'package:money_track/core/error/failures.dart';
import 'package:money_track/core/error/result.dart';
import 'package:money_track/core/services/sync_service.dart';
import 'package:money_track/data/datasources/local/transaction_local_datasource.dart';
import 'package:money_track/data/models/firestore/transaction_firestore_model.dart';
import 'package:money_track/data/models/sync/sync_operation_model.dart';
import 'package:money_track/data/models/transaction_model.dart';
import 'package:money_track/domain/entities/transaction_entity.dart';
import 'package:money_track/domain/repositories/transaction_repository.dart';

/// Enhanced transaction repository with sync capabilities
class SyncTransactionRepositoryImpl implements TransactionRepository {
  final TransactionLocalDataSource localDataSource;
  final SyncService syncService;

  SyncTransactionRepositoryImpl({
    required this.localDataSource,
    required this.syncService,
  });

  @override
  Future<Result<List<TransactionEntity>>> getAllTransactions() async {
    try {
      final transactionModels = await localDataSource.getAllTransactions();
      final transactions =
          transactionModels.map((model) => model.toEntity()).toList();
      return Success(transactions);
    } catch (e) {
      log('Error getting all transactions: $e',
          name: 'SyncTransactionRepository');
      return Error(DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<String>> addTransaction(TransactionEntity transaction) async {
    try {
      // Add to local storage first
      final transactionModel = TransactionModel.fromEntity(transaction);
      final result = await localDataSource.addTransaction(transactionModel);

      // Queue sync operation
      await _queueSyncOperation(
        SyncOperationType.create,
        transaction.id,
        transactionModel,
      );

      return Success(result);
    } catch (e) {
      log('Error adding transaction: $e', name: 'SyncTransactionRepository');
      return Error(DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<String>> editTransaction(TransactionEntity transaction) async {
    try {
      // Update local storage first
      final transactionModel = TransactionModel.fromEntity(transaction);
      final result = await localDataSource.editTransaction(transactionModel);

      // Queue sync operation
      await _queueSyncOperation(
        SyncOperationType.update,
        transaction.id,
        transactionModel,
      );

      return Success(result);
    } catch (e) {
      log('Error editing transaction: $e', name: 'SyncTransactionRepository');
      return Error(DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<void>> deleteTransaction(String transactionId) async {
    try {
      // Delete from local storage first
      await localDataSource.deleteTransaction(transactionId);

      // Queue sync operation
      await _queueDeleteSyncOperation(transactionId);

      return const Success(null);
    } catch (e) {
      log('Error deleting transaction: $e', name: 'SyncTransactionRepository');
      return Error(DatabaseFailure(message: e.toString()));
    }
  }

  /// Queue a sync operation for create/update
  Future<void> _queueSyncOperation(
    SyncOperationType operationType,
    String transactionId,
    TransactionModel transactionModel,
  ) async {
    try {
      // Get current user ID (this should come from auth service)
      final userId = await _getCurrentUserId();
      if (userId == null) {
        log('No user logged in, skipping sync operation',
            name: 'SyncTransactionRepository');
        return;
      }

      // Convert to Firestore model
      final firestoreModel =
          TransactionFirestoreModel.fromHiveModel(transactionModel, userId);

      // Create sync operation with Timestamp conversion
      final syncOperation = SyncOperationModel.createWithTimestampConversion(
        id: '${DateTime.now().microsecondsSinceEpoch}_${operationType.name}_$transactionId',
        operationType: operationType,
        dataType: SyncDataType.transaction,
        dataId: transactionId,
        data: firestoreModel.toFirestore(),
        createdAt: DateTime.now(),
        userId: userId,
      );

      await syncService.queueSyncOperation(syncOperation);
    } catch (e) {
      log('Error queuing sync operation: $e',
          name: 'SyncTransactionRepository');
      // Don't throw error here as local operation succeeded
    }
  }

  /// Queue a sync operation for delete
  Future<void> _queueDeleteSyncOperation(String transactionId) async {
    try {
      // Get current user ID
      final userId = await _getCurrentUserId();
      if (userId == null) {
        log('No user logged in, skipping sync operation',
            name: 'SyncTransactionRepository');
        return;
      }

      // Create sync operation
      final syncOperation = SyncOperationModel.delete(
        id: '${DateTime.now().microsecondsSinceEpoch}_delete_$transactionId',
        dataType: SyncDataType.transaction,
        dataId: transactionId,
        userId: userId,
      );

      await syncService.queueSyncOperation(syncOperation);
    } catch (e) {
      log('Error queuing delete sync operation: $e',
          name: 'SyncTransactionRepository');
      // Don't throw error here as local operation succeeded
    }
  }

  /// Get current user ID from auth service
  /// TODO: This should be injected or obtained from a proper auth service
  Future<String?> _getCurrentUserId() async {
    // For now, return a placeholder
    // In a real implementation, this would come from the auth service
    return 'current_user_id'; // TODO: Replace with actual user ID
  }

  /// Batch add transactions (useful for initial sync)
  Future<Result<void>> batchAddTransactions(
      List<TransactionEntity> transactions) async {
    try {
      for (final transaction in transactions) {
        final transactionModel = TransactionModel.fromEntity(transaction);
        await localDataSource.addTransaction(transactionModel);
      }
      return const Success(null);
    } catch (e) {
      log('Error batch adding transactions: $e',
          name: 'SyncTransactionRepository');
      return Error(DatabaseFailure(message: e.toString()));
    }
  }

  /// Get transactions by date range
  Future<Result<List<TransactionEntity>>> getTransactionsByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final allTransactions = await localDataSource.getAllTransactions();
      final filteredTransactions = allTransactions
          .where((transaction) =>
              transaction.date
                  .isAfter(startDate.subtract(const Duration(days: 1))) &&
              transaction.date.isBefore(endDate.add(const Duration(days: 1))))
          .map((model) => model.toEntity())
          .toList();

      return Success(filteredTransactions);
    } catch (e) {
      log('Error getting transactions by date range: $e',
          name: 'SyncTransactionRepository');
      return Error(DatabaseFailure(message: e.toString()));
    }
  }

  /// Get transactions by category
  Future<Result<List<TransactionEntity>>> getTransactionsByCategory(
      String categoryId) async {
    try {
      final allTransactions = await localDataSource.getAllTransactions();
      final filteredTransactions = allTransactions
          .where((transaction) => transaction.categoryModel.id == categoryId)
          .map((model) => model.toEntity())
          .toList();

      return Success(filteredTransactions);
    } catch (e) {
      log('Error getting transactions by category: $e',
          name: 'SyncTransactionRepository');
      return Error(DatabaseFailure(message: e.toString()));
    }
  }

  /// Get sync status for transactions
  Future<Map<String, dynamic>> getSyncStatus() async {
    return await syncService.getSyncStats();
  }

  /// Force sync transactions
  Future<Result<void>> forceSync() async {
    try {
      final result = await syncService.forceSyncNow();
      if (result.success) {
        return const Success(null);
      } else {
        return Error(NetworkFailure(message: result.error ?? 'Sync failed'));
      }
    } catch (e) {
      log('Error forcing sync: $e', name: 'SyncTransactionRepository');
      return Error(NetworkFailure(message: e.toString()));
    }
  }
}
