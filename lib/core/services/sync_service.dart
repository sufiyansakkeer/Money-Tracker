import 'dart:async';
import 'dart:developer';
import 'package:hive/hive.dart';
import 'package:money_track/core/constants/db_constants.dart';
import 'package:money_track/core/error/failures.dart';
import 'package:money_track/core/services/connectivity_service.dart';
import 'package:money_track/data/datasources/local/category_local_datasource.dart';
import 'package:money_track/data/datasources/local/transaction_local_datasource.dart';
import 'package:money_track/data/datasources/remote/category_remote_datasource.dart';
import 'package:money_track/data/datasources/remote/transaction_remote_datasource.dart';
import 'package:money_track/data/models/firestore/category_firestore_model.dart';
import 'package:money_track/data/models/firestore/transaction_firestore_model.dart';
import 'package:money_track/data/models/sync/sync_operation_model.dart';

/// Enum for sync status
enum SyncStatus {
  idle,
  syncing,
  error,
  success,
}

/// Sync result information
class SyncResult {
  final bool success;
  final String? error;
  final int syncedTransactions;
  final int syncedCategories;
  final int pendingOperations;

  const SyncResult({
    required this.success,
    this.error,
    this.syncedTransactions = 0,
    this.syncedCategories = 0,
    this.pendingOperations = 0,
  });
}

/// Service for handling data synchronization between local and remote storage
class SyncService {
  final TransactionLocalDataSource _transactionLocalDataSource;
  final CategoryLocalDataSource _categoryLocalDataSource;
  final TransactionRemoteDataSource _transactionRemoteDataSource;
  final CategoryRemoteDataSource _categoryRemoteDataSource;
  final ConnectivityService _connectivityService;
  final HiveInterface _hive;

  // Stream controllers for sync status
  final StreamController<SyncStatus> _syncStatusController =
      StreamController<SyncStatus>.broadcast();
  final StreamController<SyncResult> _syncResultController =
      StreamController<SyncResult>.broadcast();

  // Real-time listeners
  StreamSubscription<List<TransactionFirestoreModel>>?
      _transactionStreamSubscription;
  StreamSubscription<List<CategoryFirestoreModel>>? _categoryStreamSubscription;
  StreamSubscription<bool>? _connectivitySubscription;

  SyncStatus _currentStatus = SyncStatus.idle;
  String? _currentUserId;
  Timer? _periodicSyncTimer;

  SyncService({
    required TransactionLocalDataSource transactionLocalDataSource,
    required CategoryLocalDataSource categoryLocalDataSource,
    required TransactionRemoteDataSource transactionRemoteDataSource,
    required CategoryRemoteDataSource categoryRemoteDataSource,
    required ConnectivityService connectivityService,
    required HiveInterface hive,
  })  : _transactionLocalDataSource = transactionLocalDataSource,
        _categoryLocalDataSource = categoryLocalDataSource,
        _transactionRemoteDataSource = transactionRemoteDataSource,
        _categoryRemoteDataSource = categoryRemoteDataSource,
        _connectivityService = connectivityService,
        _hive = hive;

  /// Current sync status
  SyncStatus get currentStatus => _currentStatus;

  /// Stream of sync status changes
  Stream<SyncStatus> get syncStatusStream => _syncStatusController.stream;

  /// Stream of sync results
  Stream<SyncResult> get syncResultStream => _syncResultController.stream;

  /// Initialize sync service for a user
  Future<void> initializeForUser(String userId) async {
    try {
      log('Initializing sync service for user: $userId', name: 'SyncService');

      _currentUserId = userId;

      // Listen to connectivity changes
      _connectivitySubscription =
          _connectivityService.connectivityStream.listen(
        _onConnectivityChanged,
        onError: (error) {
          log('Connectivity stream error: $error', name: 'SyncService');
        },
      );

      // Start real-time listeners if connected
      if (_connectivityService.isConnected) {
        await _startRealTimeListeners();
        await _performInitialSync();
      }

      // Start periodic sync (every 5 minutes)
      _periodicSyncTimer = Timer.periodic(
        const Duration(minutes: 5),
        (_) => _performPeriodicSync(),
      );
    } catch (e) {
      log('Failed to initialize sync service: $e', name: 'SyncService');
      _updateSyncStatus(SyncStatus.error);
    }
  }

  /// Perform initial sync when user logs in
  Future<SyncResult> _performInitialSync() async {
    if (_currentUserId == null) {
      return const SyncResult(success: false, error: 'No user logged in');
    }

    log('Performing initial sync for user: $_currentUserId',
        name: 'SyncService');
    _updateSyncStatus(SyncStatus.syncing);

    try {
      // First, sync from remote to local (download user's data)
      await _syncFromRemoteToLocal();

      // Then, sync any pending local changes to remote
      await _syncPendingOperations();

      final result = SyncResult(
        success: true,
        syncedTransactions: 0, // TODO: Track actual counts
        syncedCategories: 0,
        pendingOperations: await _getPendingOperationsCount(),
      );

      _updateSyncStatus(SyncStatus.success);
      _syncResultController.add(result);

      return result;
    } catch (e) {
      log('Initial sync failed: $e', name: 'SyncService');
      _updateSyncStatus(SyncStatus.error);

      final result = SyncResult(
        success: false,
        error: e.toString(),
        pendingOperations: await _getPendingOperationsCount(),
      );

      _syncResultController.add(result);
      return result;
    }
  }

  /// Sync data from remote to local storage
  Future<void> _syncFromRemoteToLocal() async {
    if (_currentUserId == null) return;

    try {
      // Sync categories
      final remoteCategories =
          await _categoryRemoteDataSource.getAllCategories(_currentUserId!);
      for (final remoteCategory in remoteCategories) {
        await _categoryLocalDataSource
            .addCategory(remoteCategory.toHiveModel());
      }

      // Sync transactions
      final remoteTransactions = await _transactionRemoteDataSource
          .getAllTransactions(_currentUserId!);
      for (final remoteTransaction in remoteTransactions) {
        await _transactionLocalDataSource
            .addTransaction(remoteTransaction.toHiveModel());
      }

      log('Synced ${remoteCategories.length} categories and ${remoteTransactions.length} transactions from remote',
          name: 'SyncService');
    } catch (e) {
      log('Failed to sync from remote to local: $e', name: 'SyncService');
      rethrow;
    }
  }

  /// Start real-time listeners for remote data changes
  Future<void> _startRealTimeListeners() async {
    if (_currentUserId == null) return;

    try {
      // Listen to transaction changes
      _transactionStreamSubscription = _transactionRemoteDataSource
          .getTransactionsStream(_currentUserId!)
          .listen(
        _onRemoteTransactionsChanged,
        onError: (error) {
          log('Transaction stream error: $error', name: 'SyncService');
        },
      );

      // Listen to category changes
      _categoryStreamSubscription =
          _categoryRemoteDataSource.getCategoriesStream(_currentUserId!).listen(
        _onRemoteCategoriesChanged,
        onError: (error) {
          log('Category stream error: $error', name: 'SyncService');
        },
      );

      log('Started real-time listeners', name: 'SyncService');
    } catch (e) {
      log('Failed to start real-time listeners: $e', name: 'SyncService');
    }
  }

  /// Handle remote transaction changes
  void _onRemoteTransactionsChanged(
      List<TransactionFirestoreModel> remoteTransactions) async {
    try {
      for (final remoteTransaction in remoteTransactions) {
        // Check if local version exists and compare versions
        final localTransactions =
            await _transactionLocalDataSource.getAllTransactions();
        final localTransaction = localTransactions
            .where((t) => t.id == remoteTransaction.id)
            .firstOrNull;

        if (localTransaction == null) {
          // New transaction from remote
          await _transactionLocalDataSource
              .addTransaction(remoteTransaction.toHiveModel());
        } else {
          // Check for conflicts and resolve
          await _resolveTransactionConflict(
              localTransaction, remoteTransaction);
        }
      }
    } catch (e) {
      log('Error handling remote transaction changes: $e', name: 'SyncService');
    }
  }

  /// Handle remote category changes
  void _onRemoteCategoriesChanged(
      List<CategoryFirestoreModel> remoteCategories) async {
    try {
      for (final remoteCategory in remoteCategories) {
        // Check if local version exists and compare versions
        final localCategories =
            await _categoryLocalDataSource.getAllCategories();
        final localCategory =
            localCategories.where((c) => c.id == remoteCategory.id).firstOrNull;

        if (localCategory == null) {
          // New category from remote
          await _categoryLocalDataSource
              .addCategory(remoteCategory.toHiveModel());
        } else {
          // Check for conflicts and resolve
          await _resolveCategoryConflict(localCategory, remoteCategory);
        }
      }
    } catch (e) {
      log('Error handling remote category changes: $e', name: 'SyncService');
    }
  }

  /// Handle connectivity changes
  void _onConnectivityChanged(bool isConnected) async {
    log('Connectivity changed: ${isConnected ? "Connected" : "Disconnected"}',
        name: 'SyncService');

    if (isConnected && _currentUserId != null) {
      // When back online, start listeners and sync pending operations
      await _startRealTimeListeners();
      await _syncPendingOperations();
    } else {
      // When offline, stop listeners
      await _stopRealTimeListeners();
    }
  }

  /// Stop real-time listeners
  Future<void> _stopRealTimeListeners() async {
    await _transactionStreamSubscription?.cancel();
    await _categoryStreamSubscription?.cancel();
    _transactionStreamSubscription = null;
    _categoryStreamSubscription = null;
    log('Stopped real-time listeners', name: 'SyncService');
  }

  /// Update sync status and notify listeners
  void _updateSyncStatus(SyncStatus status) {
    _currentStatus = status;
    _syncStatusController.add(status);
  }

  /// Get count of pending sync operations
  Future<int> _getPendingOperationsCount() async {
    try {
      final syncBox =
          await _hive.openBox<SyncOperationModel>('sync-operations');
      return syncBox.values.length;
    } catch (e) {
      log('Error getting pending operations count: $e', name: 'SyncService');
      return 0;
    }
  }

  /// Perform periodic sync
  void _performPeriodicSync() async {
    if (_connectivityService.isConnected && _currentUserId != null) {
      await _syncPendingOperations();
    }
  }

  /// Sync pending operations to remote
  Future<void> _syncPendingOperations() async {
    if (_currentUserId == null) return;

    try {
      final syncBox =
          await _hive.openBox<SyncOperationModel>('sync-operations');
      final pendingOperations =
          syncBox.values.where((op) => op.userId == _currentUserId).toList();

      if (pendingOperations.isEmpty) return;

      log('Syncing ${pendingOperations.length} pending operations',
          name: 'SyncService');

      for (final operation in pendingOperations) {
        try {
          await _executeSyncOperation(operation);
          await syncBox.delete(operation.id);
        } catch (e) {
          log('Failed to sync operation ${operation.id}: $e',
              name: 'SyncService');

          // Update retry count
          final updatedOperation = operation.copyWith(
            retryCount: operation.retryCount + 1,
            error: e.toString(),
          );

          // Remove operation if max retries exceeded
          if (updatedOperation.retryCount >= 3) {
            await syncBox.delete(operation.id);
            log('Removed operation ${operation.id} after max retries',
                name: 'SyncService');
          } else {
            await syncBox.put(operation.id, updatedOperation);
          }
        }
      }
    } catch (e) {
      log('Error syncing pending operations: $e', name: 'SyncService');
    }
  }

  /// Execute a sync operation
  Future<void> _executeSyncOperation(SyncOperationModel operation) async {
    switch (operation.dataType) {
      case SyncDataType.transaction:
        await _executeTransactionOperation(operation);
        break;
      case SyncDataType.category:
        await _executeCategoryOperation(operation);
        break;
    }
  }

  /// Execute transaction sync operation
  Future<void> _executeTransactionOperation(
      SyncOperationModel operation) async {
    switch (operation.operationType) {
      case SyncOperationType.create:
      case SyncOperationType.update:
        // Convert DateTime objects back to Timestamps for Firestore
        final firestoreData = operation.getDataForFirestore();
        final transaction = TransactionFirestoreModel.fromMap(firestoreData);
        if (operation.operationType == SyncOperationType.create) {
          await _transactionRemoteDataSource.addTransaction(transaction);
        } else {
          await _transactionRemoteDataSource.updateTransaction(transaction);
        }
        break;
      case SyncOperationType.delete:
        await _transactionRemoteDataSource.deleteTransaction(
            operation.dataId, operation.userId);
        break;
    }
  }

  /// Execute category sync operation
  Future<void> _executeCategoryOperation(SyncOperationModel operation) async {
    switch (operation.operationType) {
      case SyncOperationType.create:
      case SyncOperationType.update:
        // Convert DateTime objects back to Timestamps for Firestore
        final firestoreData = operation.getDataForFirestore();
        final category = CategoryFirestoreModel.fromMap(firestoreData);
        if (operation.operationType == SyncOperationType.create) {
          await _categoryRemoteDataSource.addCategory(category);
        } else {
          await _categoryRemoteDataSource.updateCategory(category);
        }
        break;
      case SyncOperationType.delete:
        await _categoryRemoteDataSource.deleteCategory(
            operation.dataId, operation.userId);
        break;
    }
  }

  /// Resolve transaction conflict (last-write-wins with version check)
  Future<void> _resolveTransactionConflict(dynamic localTransaction,
      TransactionFirestoreModel remoteTransaction) async {
    try {
      // For now, implement last-write-wins strategy
      // In a more sophisticated system, you might want to present conflicts to the user

      // Convert local transaction to Firestore model for comparison
      final localFirestoreTransaction = TransactionFirestoreModel.fromHiveModel(
          localTransaction, _currentUserId!);

      // Compare versions - higher version wins
      if (remoteTransaction.version > localFirestoreTransaction.version) {
        // Remote version is newer, update local
        await _transactionLocalDataSource
            .editTransaction(remoteTransaction.toHiveModel());
        log('Updated local transaction ${remoteTransaction.id} with remote version',
            name: 'SyncService');
      } else if (localFirestoreTransaction.version >
          remoteTransaction.version) {
        // Local version is newer, update remote
        await _transactionRemoteDataSource
            .updateTransaction(localFirestoreTransaction);
        log('Updated remote transaction ${localFirestoreTransaction.id} with local version',
            name: 'SyncService');
      }
      // If versions are equal, no action needed
    } catch (e) {
      log('Error resolving transaction conflict: $e', name: 'SyncService');
    }
  }

  /// Resolve category conflict (last-write-wins with version check)
  Future<void> _resolveCategoryConflict(
      dynamic localCategory, CategoryFirestoreModel remoteCategory) async {
    try {
      // Convert local category to Firestore model for comparison
      final localFirestoreCategory =
          CategoryFirestoreModel.fromHiveModel(localCategory, _currentUserId!);

      // Compare versions - higher version wins
      if (remoteCategory.version > localFirestoreCategory.version) {
        // Remote version is newer, update local
        await _categoryLocalDataSource
            .addCategory(remoteCategory.toHiveModel());
        log('Updated local category ${remoteCategory.id} with remote version',
            name: 'SyncService');
      } else if (localFirestoreCategory.version > remoteCategory.version) {
        // Local version is newer, update remote
        await _categoryRemoteDataSource.updateCategory(localFirestoreCategory);
        log('Updated remote category ${localFirestoreCategory.id} with local version',
            name: 'SyncService');
      }
      // If versions are equal, no action needed
    } catch (e) {
      log('Error resolving category conflict: $e', name: 'SyncService');
    }
  }

  /// Clear all local data (called on logout)
  Future<void> clearLocalData() async {
    try {
      log('Clearing all local data', name: 'SyncService');

      // Stop all listeners and timers
      await _stopRealTimeListeners();
      await _connectivitySubscription?.cancel();
      _periodicSyncTimer?.cancel();

      // Clear all local data
      final categoryBox = await _hive.openBox('category-database');
      final transactionBox = await _hive.openBox(DBConstants.transactionDbName);
      final syncBox =
          await _hive.openBox<SyncOperationModel>('sync-operations');

      await categoryBox.clear();
      await transactionBox.clear();
      await syncBox.clear();

      _currentUserId = null;
      _updateSyncStatus(SyncStatus.idle);

      log('Local data cleared successfully', name: 'SyncService');
    } catch (e) {
      log('Error clearing local data: $e', name: 'SyncService');
      throw DatabaseFailure(
          message: 'Failed to clear local data: ${e.toString()}');
    }
  }

  /// Queue a sync operation for later execution
  Future<void> queueSyncOperation(SyncOperationModel operation) async {
    try {
      final syncBox =
          await _hive.openBox<SyncOperationModel>('sync-operations');
      await syncBox.put(operation.id, operation);

      log('Queued sync operation: ${operation.operationType} ${operation.dataType} ${operation.dataId}',
          name: 'SyncService');

      // If online, try to sync immediately
      if (_connectivityService.isConnected) {
        await _syncPendingOperations();
      }
    } catch (e) {
      log('Error queuing sync operation: $e', name: 'SyncService');
      throw DatabaseFailure(
          message: 'Failed to queue sync operation: ${e.toString()}');
    }
  }

  /// Force sync now (manual sync trigger)
  Future<SyncResult> forceSyncNow() async {
    if (_currentUserId == null) {
      return const SyncResult(success: false, error: 'No user logged in');
    }

    if (!_connectivityService.isConnected) {
      return const SyncResult(success: false, error: 'No internet connection');
    }

    log('Force sync triggered', name: 'SyncService');
    _updateSyncStatus(SyncStatus.syncing);

    try {
      await _syncPendingOperations();
      await _syncFromRemoteToLocal();

      final result = SyncResult(
        success: true,
        pendingOperations: await _getPendingOperationsCount(),
      );

      _updateSyncStatus(SyncStatus.success);
      _syncResultController.add(result);

      return result;
    } catch (e) {
      log('Force sync failed: $e', name: 'SyncService');
      _updateSyncStatus(SyncStatus.error);

      final result = SyncResult(
        success: false,
        error: e.toString(),
        pendingOperations: await _getPendingOperationsCount(),
      );

      _syncResultController.add(result);
      return result;
    }
  }

  /// Get sync statistics
  Future<Map<String, dynamic>> getSyncStats() async {
    try {
      final syncBox =
          await _hive.openBox<SyncOperationModel>('sync-operations');
      final pendingOps =
          syncBox.values.where((op) => op.userId == _currentUserId).toList();

      return {
        'isOnline': _connectivityService.isConnected,
        'currentStatus': _currentStatus.name,
        'pendingOperations': pendingOps.length,
        'pendingTransactions': pendingOps
            .where((op) => op.dataType == SyncDataType.transaction)
            .length,
        'pendingCategories': pendingOps
            .where((op) => op.dataType == SyncDataType.category)
            .length,
        'lastSyncTime': DateTime.now()
            .toIso8601String(), // TODO: Track actual last sync time
      };
    } catch (e) {
      log('Error getting sync stats: $e', name: 'SyncService');
      return {
        'isOnline': _connectivityService.isConnected,
        'currentStatus': _currentStatus.name,
        'pendingOperations': 0,
        'error': e.toString(),
      };
    }
  }

  /// Dispose of the sync service
  void dispose() {
    _stopRealTimeListeners();
    _connectivitySubscription?.cancel();
    _periodicSyncTimer?.cancel();
    _syncStatusController.close();
    _syncResultController.close();
  }
}
