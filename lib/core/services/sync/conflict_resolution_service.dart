import 'dart:async';
import 'dart:developer';
import 'package:money_track/data/datasources/local/category_local_datasource.dart';
import 'package:money_track/data/datasources/local/transaction_local_datasource.dart';
import 'package:money_track/data/datasources/remote/category_remote_datasource.dart';
import 'package:money_track/data/datasources/remote/transaction_remote_datasource.dart';
import 'package:money_track/data/models/firestore/category_firestore_model.dart';
import 'package:money_track/data/models/firestore/transaction_firestore_model.dart';
import 'package:money_track/data/models/category_model.dart';
import 'package:money_track/data/models/transaction_model.dart';
import 'sync_models.dart';

/// Handles conflict detection and resolution for sync operations
class ConflictResolutionService {
  final TransactionLocalDataSource _transactionLocalDataSource;
  final CategoryLocalDataSource _categoryLocalDataSource;
  final TransactionRemoteDataSource _transactionRemoteDataSource;
  final CategoryRemoteDataSource _categoryRemoteDataSource;

  // Conflict resolution configuration
  ConflictResolutionStrategy _conflictResolutionStrategy =
      ConflictResolutionStrategy.lastWriteWins;
  final List<ConflictInfo> _pendingConflicts = [];
  final StreamController<List<ConflictInfo>> _conflictController =
      StreamController<List<ConflictInfo>>.broadcast();

  ConflictResolutionService({
    required TransactionLocalDataSource transactionLocalDataSource,
    required CategoryLocalDataSource categoryLocalDataSource,
    required TransactionRemoteDataSource transactionRemoteDataSource,
    required CategoryRemoteDataSource categoryRemoteDataSource,
  })  : _transactionLocalDataSource = transactionLocalDataSource,
        _categoryLocalDataSource = categoryLocalDataSource,
        _transactionRemoteDataSource = transactionRemoteDataSource,
        _categoryRemoteDataSource = categoryRemoteDataSource;

  /// Stream of pending conflicts (for manual resolution)
  Stream<List<ConflictInfo>> get conflictStream => _conflictController.stream;

  /// Current conflict resolution strategy
  ConflictResolutionStrategy get conflictResolutionStrategy =>
      _conflictResolutionStrategy;

  /// Set conflict resolution strategy
  void setConflictResolutionStrategy(ConflictResolutionStrategy strategy) {
    _conflictResolutionStrategy = strategy;
    log('Conflict resolution strategy changed to: ${strategy.name}',
        name: 'ConflictResolutionService');
  }

  /// Get pending conflicts
  List<ConflictInfo> get pendingConflicts =>
      List.unmodifiable(_pendingConflicts);

  /// Determine conflict resolution based on strategy
  ConflictResolution determineResolution(
    DateTime localUpdatedAt,
    DateTime remoteUpdatedAt,
    int localVersion,
    int remoteVersion,
  ) {
    switch (_conflictResolutionStrategy) {
      case ConflictResolutionStrategy.lastWriteWins:
        if (localUpdatedAt.isAfter(remoteUpdatedAt)) {
          return ConflictResolution.useLocal;
        } else if (remoteUpdatedAt.isAfter(localUpdatedAt)) {
          return ConflictResolution.useRemote;
        } else {
          // Same timestamp, use version
          return localVersion > remoteVersion
              ? ConflictResolution.useLocal
              : ConflictResolution.useRemote;
        }

      case ConflictResolutionStrategy.remoteWins:
        return ConflictResolution.useRemote;

      case ConflictResolutionStrategy.localWins:
        return ConflictResolution.useLocal;

      case ConflictResolutionStrategy.versionBased:
        if (localVersion > remoteVersion) {
          return ConflictResolution.useLocal;
        } else if (remoteVersion > localVersion) {
          return ConflictResolution.useRemote;
        } else {
          // Same version, use timestamp
          return localUpdatedAt.isAfter(remoteUpdatedAt)
              ? ConflictResolution.useLocal
              : ConflictResolution.useRemote;
        }

      case ConflictResolutionStrategy.manual:
        return ConflictResolution.requiresManualResolution;
    }
  }

  /// Resolve transaction conflict
  Future<BidirectionalSyncResult> resolveTransactionConflict(
    TransactionModel localTransaction,
    TransactionFirestoreModel remoteTransaction,
  ) async {
    try {
      // Convert local transaction to Firestore model for comparison
      final localFirestoreTransaction = TransactionFirestoreModel.fromHiveModel(
        localTransaction,
        remoteTransaction.userId,
      );

      final resolution = determineResolution(
        localFirestoreTransaction.updatedAt,
        remoteTransaction.updatedAt,
        localFirestoreTransaction.version,
        remoteTransaction.version,
      );

      switch (resolution) {
        case ConflictResolution.useLocal:
          // Update remote with local version
          final updatedTransaction = localFirestoreTransaction.copyWith(
            version: localFirestoreTransaction.version + 1,
            updatedAt: DateTime.now(),
          );
          await _transactionRemoteDataSource
              .updateTransaction(updatedTransaction);
          return const BidirectionalSyncResult(remoteUpdated: true);

        case ConflictResolution.useRemote:
          // Update local with remote version
          await _transactionLocalDataSource
              .editTransaction(remoteTransaction.toHiveModel());
          return const BidirectionalSyncResult(localUpdated: true);

        case ConflictResolution.requiresManualResolution:
          // Add to pending conflicts
          final conflict = ConflictInfo(
            id: localTransaction.id!,
            dataType: 'transaction',
            localData: localFirestoreTransaction.toFirestore(),
            remoteData: remoteTransaction.toFirestore(),
            localUpdatedAt: localFirestoreTransaction.updatedAt,
            remoteUpdatedAt: remoteTransaction.updatedAt,
            localVersion: localFirestoreTransaction.version,
            remoteVersion: remoteTransaction.version,
          );
          _pendingConflicts.add(conflict);
          _conflictController.add(List.from(_pendingConflicts));
          return const BidirectionalSyncResult();

        case ConflictResolution.noConflict:
          return const BidirectionalSyncResult();
      }
    } catch (e) {
      log('Error resolving transaction conflict: $e',
          name: 'ConflictResolutionService');
      return BidirectionalSyncResult(error: e.toString());
    }
  }

  /// Resolve category conflict
  Future<BidirectionalSyncResult> resolveCategoryConflict(
    CategoryModel localCategory,
    CategoryFirestoreModel remoteCategory,
  ) async {
    try {
      // Convert local category to Firestore model for comparison
      final localFirestoreCategory = CategoryFirestoreModel.fromHiveModel(
        localCategory,
        remoteCategory.userId,
      );

      final resolution = determineResolution(
        localFirestoreCategory.updatedAt,
        remoteCategory.updatedAt,
        localFirestoreCategory.version,
        remoteCategory.version,
      );

      switch (resolution) {
        case ConflictResolution.useLocal:
          // Update remote with local version
          final updatedCategory = localFirestoreCategory.copyWith(
            version: localFirestoreCategory.version + 1,
            updatedAt: DateTime.now(),
          );
          await _categoryRemoteDataSource.updateCategory(updatedCategory);
          return const BidirectionalSyncResult(remoteUpdated: true);

        case ConflictResolution.useRemote:
          // Update local with remote version
          await _categoryLocalDataSource
              .addCategory(remoteCategory.toHiveModel());
          return const BidirectionalSyncResult(localUpdated: true);

        case ConflictResolution.requiresManualResolution:
          // Add to pending conflicts
          final conflict = ConflictInfo(
            id: localCategory.id,
            dataType: 'category',
            localData: localFirestoreCategory.toFirestore(),
            remoteData: remoteCategory.toFirestore(),
            localUpdatedAt: localFirestoreCategory.updatedAt,
            remoteUpdatedAt: remoteCategory.updatedAt,
            localVersion: localFirestoreCategory.version,
            remoteVersion: remoteCategory.version,
          );
          _pendingConflicts.add(conflict);
          _conflictController.add(List.from(_pendingConflicts));
          return const BidirectionalSyncResult();

        case ConflictResolution.noConflict:
          return const BidirectionalSyncResult();
      }
    } catch (e) {
      log('Error resolving category conflict: $e',
          name: 'ConflictResolutionService');
      return BidirectionalSyncResult(error: e.toString());
    }
  }

  /// Resolve a conflict manually by choosing local or remote version
  Future<void> resolveConflictManually(String conflictId, bool useLocal) async {
    try {
      final conflictIndex =
          _pendingConflicts.indexWhere((c) => c.id == conflictId);
      if (conflictIndex == -1) {
        log('Conflict not found: $conflictId',
            name: 'ConflictResolutionService');
        return;
      }

      final conflict = _pendingConflicts[conflictIndex];

      if (conflict.dataType == 'transaction') {
        if (useLocal) {
          final localTransaction =
              TransactionFirestoreModel.fromMap(conflict.localData);
          final updatedTransaction = localTransaction.copyWith(
            version: localTransaction.version + 1,
            updatedAt: DateTime.now(),
          );
          await _transactionRemoteDataSource
              .updateTransaction(updatedTransaction);
        } else {
          final remoteTransaction =
              TransactionFirestoreModel.fromMap(conflict.remoteData);
          await _transactionLocalDataSource
              .editTransaction(remoteTransaction.toHiveModel());
        }
      } else if (conflict.dataType == 'category') {
        if (useLocal) {
          final localCategory =
              CategoryFirestoreModel.fromMap(conflict.localData);
          final updatedCategory = localCategory.copyWith(
            version: localCategory.version + 1,
            updatedAt: DateTime.now(),
          );
          await _categoryRemoteDataSource.updateCategory(updatedCategory);
        } else {
          final remoteCategory =
              CategoryFirestoreModel.fromMap(conflict.remoteData);
          await _categoryLocalDataSource
              .addCategory(remoteCategory.toHiveModel());
        }
      }

      // Remove resolved conflict
      _pendingConflicts.removeAt(conflictIndex);
      _conflictController.add(List.from(_pendingConflicts));

      log('Manually resolved conflict: $conflictId (used ${useLocal ? 'local' : 'remote'})',
          name: 'ConflictResolutionService');
    } catch (e) {
      log('Error resolving conflict manually: $e',
          name: 'ConflictResolutionService');
      rethrow;
    }
  }

  /// Clear all pending conflicts
  void clearPendingConflicts() {
    _pendingConflicts.clear();
    _conflictController.add(List.from(_pendingConflicts));
    log('Cleared all pending conflicts', name: 'ConflictResolutionService');
  }

  /// Get conflict statistics
  Map<String, dynamic> getConflictStats() {
    final conflictsByType = <String, int>{};
    for (final conflict in _pendingConflicts) {
      final type = conflict.dataType;
      conflictsByType[type] = (conflictsByType[type] ?? 0) + 1;
    }

    return {
      'totalPendingConflicts': _pendingConflicts.length,
      'conflictsByType': conflictsByType,
      'resolutionStrategy': _conflictResolutionStrategy.name,
    };
  }

  /// Dispose of resources
  void dispose() {
    _conflictController.close();
    _pendingConflicts.clear();
  }
}
