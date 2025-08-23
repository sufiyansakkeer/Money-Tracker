import 'dart:developer';
import 'package:money_track/data/datasources/local/category_local_datasource.dart';
import 'package:money_track/data/datasources/local/transaction_local_datasource.dart';
import 'package:money_track/data/datasources/remote/category_remote_datasource.dart';
import 'package:money_track/data/datasources/remote/transaction_remote_datasource.dart';
import 'package:money_track/data/models/firestore/category_firestore_model.dart';
import 'package:money_track/data/models/firestore/transaction_firestore_model.dart';
import 'conflict_resolution_service.dart';
import 'object_pool_manager.dart';
import 'sync_progress_manager.dart';

/// Manages bidirectional synchronization between local and remote data
class BidirectionalSyncManager {
  final TransactionLocalDataSource _transactionLocalDataSource;
  final CategoryLocalDataSource _categoryLocalDataSource;
  final TransactionRemoteDataSource _transactionRemoteDataSource;
  final CategoryRemoteDataSource _categoryRemoteDataSource;
  final ConflictResolutionService _conflictResolutionService;
  final ObjectPoolManager _objectPoolManager;
  final SyncProgressManager _syncProgressManager;

  // Sync tracking
  final Map<String, int> _syncSessionStats = {
    'transactions': 0,
    'categories': 0,
    'failed': 0,
  };

  BidirectionalSyncManager({
    required TransactionLocalDataSource transactionLocalDataSource,
    required CategoryLocalDataSource categoryLocalDataSource,
    required TransactionRemoteDataSource transactionRemoteDataSource,
    required CategoryRemoteDataSource categoryRemoteDataSource,
    required ConflictResolutionService conflictResolutionService,
    required ObjectPoolManager objectPoolManager,
    required SyncProgressManager syncProgressManager,
  })  : _transactionLocalDataSource = transactionLocalDataSource,
        _categoryLocalDataSource = categoryLocalDataSource,
        _transactionRemoteDataSource = transactionRemoteDataSource,
        _categoryRemoteDataSource = categoryRemoteDataSource,
        _conflictResolutionService = conflictResolutionService,
        _objectPoolManager = objectPoolManager,
        _syncProgressManager = syncProgressManager;

  /// Get current sync session stats
  Map<String, int> get syncSessionStats => Map.unmodifiable(_syncSessionStats);

  /// Reset sync session stats
  void resetSyncSessionStats() {
    _syncSessionStats['transactions'] = 0;
    _syncSessionStats['categories'] = 0;
    _syncSessionStats['failed'] = 0;
  }

  /// Optimized bidirectional category synchronization with batch processing
  Future<void> performBidirectionalCategorySync(String userId) async {
    // Use pooled objects to reduce memory allocations - declare outside try block for cleanup access
    final localCategoryMap = _objectPoolManager.getPooledMap();
    final remoteCategoryMap = _objectPoolManager.getPooledMap();
    final localCategoriesToUpload = _objectPoolManager.getPooledList();

    try {
      // Get local and remote data
      final localCategories = await _categoryLocalDataSource.getAllCategories();
      final remoteCategories =
          await _categoryRemoteDataSource.getAllCategories(userId);

      // Build maps efficiently
      for (final cat in localCategories) {
        localCategoryMap[cat.id] = cat;
      }
      for (final cat in remoteCategories) {
        remoteCategoryMap[cat.id] = cat;
      }

      // Pre-filter local categories that need uploading
      for (final cat in localCategories) {
        if (!remoteCategoryMap.containsKey(cat.id)) {
          localCategoriesToUpload.add(cat);
        }
      }

      int syncedFromRemote = 0;
      int syncedToRemote = 0;

      // Process remote categories in batches
      await _syncProgressManager.processBatch(
        remoteCategories,
        'Syncing categories from remote',
        (remoteCategory, index) async {
          final localCategory = localCategoryMap[remoteCategory.id];

          if (localCategory == null) {
            // New category from remote - add to local
            await _categoryLocalDataSource
                .addCategory(remoteCategory.toHiveModel());
            syncedFromRemote++;
          } else {
            // Category exists locally - check for conflicts and resolve
            final syncResult = await _conflictResolutionService
                .resolveCategoryConflict(localCategory, remoteCategory);
            if (syncResult.localUpdated) syncedFromRemote++;
            if (syncResult.remoteUpdated) syncedToRemote++;
          }
        },
      );

      // Process local categories that need uploading in batches
      await _syncProgressManager.processBatch(
        localCategoriesToUpload,
        'Uploading categories to remote',
        (localCategory, index) async {
          // Convert to Firestore model once
          final firestoreCategory =
              CategoryFirestoreModel.fromHiveModel(localCategory, userId);
          await _categoryRemoteDataSource.addCategory(firestoreCategory);
          syncedToRemote++;
        },
      );

      // Update session stats atomically
      _syncSessionStats['categories'] = (_syncSessionStats['categories']! +
          syncedFromRemote +
          syncedToRemote);

      log('Category bidirectional sync completed: $syncedFromRemote from remote, $syncedToRemote to remote',
          name: 'BidirectionalSyncManager');

      // Return pooled objects for reuse
      _objectPoolManager.returnMapToPool(localCategoryMap);
      _objectPoolManager.returnMapToPool(remoteCategoryMap);
      _objectPoolManager.returnListToPool(localCategoriesToUpload);
    } catch (e) {
      log('Error in bidirectional category sync: $e',
          name: 'BidirectionalSyncManager');

      // Ensure cleanup even on error
      try {
        _objectPoolManager.returnMapToPool(localCategoryMap);
        _objectPoolManager.returnMapToPool(remoteCategoryMap);
        _objectPoolManager.returnListToPool(localCategoriesToUpload);
      } catch (_) {
        // Ignore cleanup errors
      }

      rethrow;
    }
  }

  /// Optimized bidirectional transaction synchronization with batch processing
  Future<void> performBidirectionalTransactionSync(String userId) async {
    // Use pooled objects to reduce memory allocations - declare outside try block for cleanup access
    final localTransactionMap = _objectPoolManager.getPooledMap();
    final remoteTransactionMap = _objectPoolManager.getPooledMap();
    final localTransactionsToUpload = _objectPoolManager.getPooledList();

    try {
      // Get local and remote data
      final localTransactions =
          await _transactionLocalDataSource.getAllTransactions();
      final remoteTransactions =
          await _transactionRemoteDataSource.getAllTransactions(userId);

      // Build maps efficiently
      for (final trans in localTransactions) {
        if (trans.id != null) {
          localTransactionMap[trans.id!] = trans;
        }
      }
      for (final trans in remoteTransactions) {
        remoteTransactionMap[trans.id] = trans;
      }

      // Pre-filter local transactions that need uploading
      for (final trans in localTransactions) {
        if (trans.id != null && !remoteTransactionMap.containsKey(trans.id!)) {
          localTransactionsToUpload.add(trans);
        }
      }

      int syncedFromRemote = 0;
      int syncedToRemote = 0;

      // Process remote transactions in batches
      await _syncProgressManager.processBatch(
        remoteTransactions,
        'Syncing transactions from remote',
        (remoteTransaction, index) async {
          final localTransaction = localTransactionMap[remoteTransaction.id];

          if (localTransaction == null) {
            // New transaction from remote - add to local
            await _transactionLocalDataSource
                .addTransaction(remoteTransaction.toHiveModel());
            syncedFromRemote++;
          } else {
            // Transaction exists locally - check for conflicts and resolve
            final syncResult =
                await _conflictResolutionService.resolveTransactionConflict(
                    localTransaction, remoteTransaction);
            if (syncResult.localUpdated) syncedFromRemote++;
            if (syncResult.remoteUpdated) syncedToRemote++;
          }
        },
      );

      // Process local transactions that need uploading in batches
      await _syncProgressManager.processBatch(
        localTransactionsToUpload,
        'Uploading transactions to remote',
        (localTransaction, index) async {
          // Convert to Firestore model once
          final firestoreTransaction =
              TransactionFirestoreModel.fromHiveModel(localTransaction, userId);
          await _transactionRemoteDataSource
              .addTransaction(firestoreTransaction);
          syncedToRemote++;
        },
      );

      // Update session stats atomically
      _syncSessionStats['transactions'] = (_syncSessionStats['transactions']! +
          syncedFromRemote +
          syncedToRemote);

      log('Transaction bidirectional sync completed: $syncedFromRemote from remote, $syncedToRemote to remote',
          name: 'BidirectionalSyncManager');

      // Return pooled objects for reuse
      _objectPoolManager.returnMapToPool(localTransactionMap);
      _objectPoolManager.returnMapToPool(remoteTransactionMap);
      _objectPoolManager.returnListToPool(localTransactionsToUpload);
    } catch (e) {
      log('Error in bidirectional transaction sync: $e',
          name: 'BidirectionalSyncManager');

      // Ensure cleanup even on error
      try {
        _objectPoolManager.returnMapToPool(localTransactionMap);
        _objectPoolManager.returnMapToPool(remoteTransactionMap);
        _objectPoolManager.returnListToPool(localTransactionsToUpload);
      } catch (_) {
        // Ignore cleanup errors
      }

      rethrow;
    }
  }

  /// Perform both category and transaction bidirectional sync
  Future<void> performFullBidirectionalSync(String userId) async {
    try {
      resetSyncSessionStats();

      log('Starting full bidirectional sync for user: $userId',
          name: 'BidirectionalSyncManager');

      await performBidirectionalCategorySync(userId);
      await performBidirectionalTransactionSync(userId);

      log('Full bidirectional sync completed. Categories: ${_syncSessionStats['categories']}, Transactions: ${_syncSessionStats['transactions']}',
          name: 'BidirectionalSyncManager');
    } catch (e) {
      _syncSessionStats['failed'] = _syncSessionStats['failed']! + 1;
      log('Full bidirectional sync failed: $e',
          name: 'BidirectionalSyncManager');
      rethrow;
    }
  }
}
