import 'dart:async';
import 'dart:developer';
import 'package:hive_ce/hive.dart';
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
import 'sync/sync_models.dart';
import 'sync/object_pool_manager.dart';
import 'sync/sync_progress_manager.dart';
import 'sync/sync_error_handler.dart';
import 'sync/conflict_resolution_service.dart';
import 'sync/bidirectional_sync_manager.dart';

/// Service for handling data synchronization between local and remote storage
class SyncService {
  final TransactionLocalDataSource _transactionLocalDataSource;
  final CategoryLocalDataSource _categoryLocalDataSource;
  final TransactionRemoteDataSource _transactionRemoteDataSource;
  final CategoryRemoteDataSource _categoryRemoteDataSource;
  final ConnectivityService _connectivityService;
  final HiveInterface _hive;

  // Extracted services
  late final ObjectPoolManager _objectPoolManager;
  late final SyncProgressManager _syncProgressManager;
  late final SyncErrorHandler _syncErrorHandler;
  late final ConflictResolutionService _conflictResolutionService;
  late final BidirectionalSyncManager _bidirectionalSyncManager;

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

  // Sync tracking fields
  DateTime? _lastSyncTime;
  int _totalSyncedTransactions = 0;
  int _totalSyncedCategories = 0;
  int _totalFailedOperations = 0;

  // Offline/Online state management
  bool _wasOffline = false;
  DateTime? _lastOnlineTime;
  DateTime? _lastOfflineTime;
  final StreamController<bool> _connectivityStatusController =
      StreamController<bool>.broadcast();

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
        _hive = hive {
    // Initialize extracted services
    _objectPoolManager = ObjectPoolManager();
    _syncProgressManager = SyncProgressManager();
    _syncErrorHandler = SyncErrorHandler();
    _conflictResolutionService = ConflictResolutionService(
      transactionLocalDataSource: _transactionLocalDataSource,
      categoryLocalDataSource: _categoryLocalDataSource,
      transactionRemoteDataSource: _transactionRemoteDataSource,
      categoryRemoteDataSource: _categoryRemoteDataSource,
    );
    _bidirectionalSyncManager = BidirectionalSyncManager(
      transactionLocalDataSource: _transactionLocalDataSource,
      categoryLocalDataSource: _categoryLocalDataSource,
      transactionRemoteDataSource: _transactionRemoteDataSource,
      categoryRemoteDataSource: _categoryRemoteDataSource,
      conflictResolutionService: _conflictResolutionService,
      objectPoolManager: _objectPoolManager,
      syncProgressManager: _syncProgressManager,
    );
  }

  /// Current sync status
  SyncStatus get currentStatus => _currentStatus;

  /// Stream of sync status changes
  Stream<SyncStatus> get syncStatusStream => _syncStatusController.stream;

  /// Stream of sync results
  Stream<SyncResult> get syncResultStream => _syncResultController.stream;

  /// Stream of pending conflicts (for manual resolution)
  Stream<List<ConflictInfo>> get conflictStream =>
      _conflictResolutionService.conflictStream;

  /// Current conflict resolution strategy
  ConflictResolutionStrategy get conflictResolutionStrategy =>
      _conflictResolutionService.conflictResolutionStrategy;

  /// Set conflict resolution strategy
  void setConflictResolutionStrategy(ConflictResolutionStrategy strategy) {
    _conflictResolutionService.setConflictResolutionStrategy(strategy);
  }

  /// Get pending conflicts
  List<ConflictInfo> get pendingConflicts =>
      _conflictResolutionService.pendingConflicts;

  /// Resolve a conflict manually by choosing local or remote version
  Future<void> resolveConflictManually(String conflictId, bool useLocal) async {
    await _conflictResolutionService.resolveConflictManually(
        conflictId, useLocal);
  }

  /// Clear all pending conflicts
  void clearPendingConflicts() {
    _conflictResolutionService.clearPendingConflicts();
  }

  /// Stream of connectivity status changes
  Stream<bool> get connectivityStatusStream =>
      _connectivityStatusController.stream;

  /// Get offline/online statistics
  Map<String, dynamic> get connectivityStats => {
        'isOnline': _connectivityService.isConnected,
        'wasOffline': _wasOffline,
        'lastOnlineTime': _lastOnlineTime?.toIso8601String(),
        'lastOfflineTime': _lastOfflineTime?.toIso8601String(),
        'consecutiveFailures': _syncErrorHandler.consecutiveFailures,
        'maxRetryAttempts': _syncErrorHandler.maxRetryAttempts,
      };

  /// Stream of sync progress updates
  Stream<SyncProgress> get progressStream =>
      _syncProgressManager.progressStream;

  /// Current sync progress
  SyncProgress? get currentProgress => _syncProgressManager.currentProgress;

  /// Stream of sync errors
  Stream<SyncError> get errorStream => _syncErrorHandler.errorStream;

  /// Get recent sync errors
  List<SyncError> get recentErrors => _syncErrorHandler.recentErrors;

  /// Clear error history
  void clearErrorHistory() {
    _syncErrorHandler.clearErrorHistory();
  }

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

    final syncStartTime = DateTime.now();
    _resetSyncSessionStats();

    try {
      // First, sync from remote to local (download user's data)
      await _syncFromRemoteToLocal();

      // Then, sync any pending local changes to remote
      await _syncPendingOperations();

      final syncEndTime = DateTime.now();
      final syncDuration = syncEndTime.difference(syncStartTime);
      _lastSyncTime = syncEndTime;

      _syncProgressManager.clearProgress();

      final syncStats = _bidirectionalSyncManager.syncSessionStats;
      final result = SyncResult(
        success: true,
        syncedTransactions: syncStats['transactions']!,
        syncedCategories: syncStats['categories']!,
        failedOperations: syncStats['failed']!,
        pendingOperations: await _getPendingOperationsCount(),
        lastSyncTime: _lastSyncTime,
        syncDuration: syncDuration,
        additionalInfo: {
          'syncType': 'initial',
          'totalItems': syncStats['transactions']! + syncStats['categories']!,
          'offlineRecovery': _wasOffline,
        },
      );

      // Update total counters
      _totalSyncedTransactions += syncStats['transactions']!;
      _totalSyncedCategories += syncStats['categories']!;
      _totalFailedOperations += syncStats['failed']!;

      _updateSyncStatus(SyncStatus.success);
      _syncResultController.add(result);

      log('Initial sync completed: ${syncStats['transactions']} transactions, ${syncStats['categories']} categories in ${syncDuration.inMilliseconds}ms',
          name: 'SyncService');

      return result;
    } catch (e) {
      log('Initial sync failed: $e', name: 'SyncService');
      _updateSyncStatus(SyncStatus.error);

      final syncEndTime = DateTime.now();
      final syncDuration = syncEndTime.difference(syncStartTime);

      final syncStats = _bidirectionalSyncManager.syncSessionStats;
      final result = SyncResult(
        success: false,
        error: e.toString(),
        syncedTransactions: syncStats['transactions']!,
        syncedCategories: syncStats['categories']!,
        failedOperations: syncStats['failed']! + 1,
        pendingOperations: await _getPendingOperationsCount(),
        lastSyncTime: _lastSyncTime,
        syncDuration: syncDuration,
      );

      _syncResultController.add(result);
      return result;
    }
  }

  /// Sync data from remote to local storage with enhanced bidirectional logic
  Future<void> _syncFromRemoteToLocal() async {
    if (_currentUserId == null) return;

    try {
      // Perform bidirectional sync for categories and transactions
      await _bidirectionalSyncManager
          .performFullBidirectionalSync(_currentUserId!);

      // Update local session stats from the bidirectional sync manager
      final syncStats = _bidirectionalSyncManager.syncSessionStats;
      _totalSyncedTransactions += syncStats['transactions']!;
      _totalSyncedCategories += syncStats['categories']!;
      _totalFailedOperations += syncStats['failed']!;
    } catch (e) {
      log('Failed to sync from remote to local: $e', name: 'SyncService');
      _totalFailedOperations++;
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

  /// Optimized handler for remote transaction changes with batch processing
  void _onRemoteTransactionsChanged(
      List<TransactionFirestoreModel> remoteTransactions) async {
    if (remoteTransactions.isEmpty) return;

    try {
      // Get all local transactions once to avoid repeated database queries
      final localTransactions =
          await _transactionLocalDataSource.getAllTransactions();

      // Use pooled map for efficient lookups
      final localTransactionMap = _objectPoolManager.getPooledMap();

      try {
        // Build lookup map once
        for (final trans in localTransactions) {
          if (trans.id != null) {
            localTransactionMap[trans.id!] = trans;
          }
        }

        // Process remote changes in batches with UI yielding
        await _syncProgressManager.processBatch(
          remoteTransactions,
          'Processing remote transaction changes',
          (remoteTransaction, index) async {
            final localTransaction = localTransactionMap[remoteTransaction.id];

            if (localTransaction == null) {
              // New transaction from remote
              await _transactionLocalDataSource
                  .addTransaction(remoteTransaction.toHiveModel());
            } else {
              // Check for conflicts and resolve
              final syncResult =
                  await _conflictResolutionService.resolveTransactionConflict(
                      localTransaction, remoteTransaction);
              if (syncResult.error != null) {
                log('Transaction conflict resolution error: ${syncResult.error}',
                    name: 'SyncService');
              }
            }
          },
        );
      } finally {
        // Always return pooled object
        _objectPoolManager.returnMapToPool(localTransactionMap);
      }
    } catch (e) {
      log('Error handling remote transaction changes: $e', name: 'SyncService');
    }
  }

  /// Optimized handler for remote category changes with batch processing
  void _onRemoteCategoriesChanged(
      List<CategoryFirestoreModel> remoteCategories) async {
    if (remoteCategories.isEmpty) return;

    try {
      // Get all local categories once to avoid repeated database queries
      final localCategories = await _categoryLocalDataSource.getAllCategories();

      // Use pooled map for efficient lookups
      final localCategoryMap = _objectPoolManager.getPooledMap();

      try {
        // Build lookup map once
        for (final cat in localCategories) {
          localCategoryMap[cat.id] = cat;
        }

        // Process remote changes in batches with UI yielding
        await _syncProgressManager.processBatch(
          remoteCategories,
          'Processing remote category changes',
          (remoteCategory, index) async {
            final localCategory = localCategoryMap[remoteCategory.id];

            if (localCategory == null) {
              // New category from remote
              await _categoryLocalDataSource
                  .addCategory(remoteCategory.toHiveModel());
            } else {
              // Check for conflicts and resolve
              final syncResult = await _conflictResolutionService
                  .resolveCategoryConflict(localCategory, remoteCategory);
              if (syncResult.error != null) {
                log('Category conflict resolution error: ${syncResult.error}',
                    name: 'SyncService');
              }
            }
          },
        );
      } finally {
        // Always return pooled object
        _objectPoolManager.returnMapToPool(localCategoryMap);
      }
    } catch (e) {
      log('Error handling remote category changes: $e', name: 'SyncService');
    }
  }

  /// Handle connectivity changes with enhanced offline/online state management
  void _onConnectivityChanged(bool isConnected) async {
    final now = DateTime.now();

    log('Connectivity changed: ${isConnected ? "Connected" : "Disconnected"}',
        name: 'SyncService');

    // Update connectivity status stream
    _connectivityStatusController.add(isConnected);

    if (isConnected) {
      // Coming back online
      if (_wasOffline) {
        final offlineDuration = _lastOfflineTime != null
            ? now.difference(_lastOfflineTime!)
            : Duration.zero;
        log('Back online after ${offlineDuration.inMinutes} minutes offline',
            name: 'SyncService');
      }

      _lastOnlineTime = now;
      _wasOffline = false;

      if (_currentUserId != null) {
        // Cancel any pending retry
        _syncErrorHandler.cancelRetry();

        try {
          // Start real-time listeners
          await _startRealTimeListeners();

          // Perform comprehensive sync when coming back online
          await _performOnlineRecoverySync();

          // Reset consecutive failures on successful reconnection
          _syncErrorHandler.resetConsecutiveFailures();
        } catch (e) {
          log('Error during online recovery: $e', name: 'SyncService');

          // Categorize and handle the error
          final syncError = _syncErrorHandler.categorizeError(e);
          _syncErrorHandler.handleSyncError(syncError);
          _syncErrorHandler.incrementConsecutiveFailures();

          // Schedule retry if error is retryable
          if (_syncErrorHandler.shouldRetry(syncError)) {
            _syncErrorHandler.scheduleRetry(() => _performOnlineRecoverySync());
          } else {
            log('Non-retryable error encountered, stopping retry attempts',
                name: 'SyncService');
          }
        }
      }
    } else {
      // Going offline
      _lastOfflineTime = now;
      _wasOffline = true;

      // Stop real-time listeners to conserve resources
      await _stopRealTimeListeners();

      log('Went offline - sync operations will be queued', name: 'SyncService');
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

  /// Perform comprehensive sync when coming back online
  Future<void> _performOnlineRecoverySync() async {
    if (_currentUserId == null) return;

    log('Performing online recovery sync', name: 'SyncService');
    _updateSyncStatus(SyncStatus.syncing);

    try {
      // First, sync any pending local operations to remote
      await _syncPendingOperations();

      // Then, perform full bidirectional sync to catch up on remote changes
      await _syncFromRemoteToLocal();

      // Get final counts for reporting
      final pendingCount = await _getPendingOperationsCount();

      log('Online recovery sync completed. Pending operations: $pendingCount',
          name: 'SyncService');

      _updateSyncStatus(SyncStatus.success);
    } catch (e) {
      log('Online recovery sync failed: $e', name: 'SyncService');
      _updateSyncStatus(SyncStatus.error);
      rethrow;
    }
  }

  /// Update sync status and notify listeners
  void _updateSyncStatus(SyncStatus status) {
    _currentStatus = status;
    _syncStatusController.add(status);
  }

  /// Reset sync session statistics
  void _resetSyncSessionStats() {
    _bidirectionalSyncManager.resetSyncSessionStats();
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

      int successfulOperations = 0;
      int failedOperations = 0;

      // Process pending operations in batches with UI thread yielding
      await _syncProgressManager.processBatch(
        pendingOperations,
        'Syncing pending operations',
        (operation, index) async {
          try {
            await _executeSyncOperation(operation);
            await syncBox.delete(operation.id);
            successfulOperations++;

            // Update session stats based on operation type
            if (operation.dataType == SyncDataType.transaction) {
              _totalSyncedTransactions++;
            } else if (operation.dataType == SyncDataType.category) {
              _totalSyncedCategories++;
            }
          } catch (e) {
            failedOperations++;

            // Categorize and handle the error
            final syncError = _syncErrorHandler.categorizeError(e,
                operationId: operation.id, retryCount: operation.retryCount);
            _syncErrorHandler.handleSyncError(syncError);

            // Update retry count
            final updatedOperation = operation.copyWith(
              retryCount: operation.retryCount + 1,
              error: e.toString(),
            );

            // Check if error is retryable and hasn't exceeded max retries
            if (!syncError.isRetryable || updatedOperation.retryCount >= 3) {
              await syncBox.delete(operation.id);
              _totalFailedOperations++;
            } else {
              await syncBox.put(operation.id, updatedOperation);
            }
          }
        },
      );

      log('Completed pending operations sync: $successfulOperations successful, $failedOperations failed',
          name: 'SyncService');
    } catch (e) {
      log('Error syncing pending operations: $e', name: 'SyncService');
      _totalFailedOperations++;
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

      // Reset sync tracking counters
      _lastSyncTime = null;
      _totalSyncedTransactions = 0;
      _totalSyncedCategories = 0;
      _totalFailedOperations = 0;
      _resetSyncSessionStats();

      // Reset offline/online state
      _wasOffline = false;
      _lastOnlineTime = null;
      _lastOfflineTime = null;

      // Clear extracted services state
      _syncErrorHandler.resetConsecutiveFailures();
      _syncErrorHandler.cancelRetry();
      _conflictResolutionService.clearPendingConflicts();

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

    final syncStartTime = DateTime.now();
    _resetSyncSessionStats();

    try {
      await _syncPendingOperations();
      await _syncFromRemoteToLocal();

      final syncEndTime = DateTime.now();
      final syncDuration = syncEndTime.difference(syncStartTime);
      _lastSyncTime = syncEndTime;

      final syncStats = _bidirectionalSyncManager.syncSessionStats;
      final result = SyncResult(
        success: true,
        syncedTransactions: syncStats['transactions']!,
        syncedCategories: syncStats['categories']!,
        failedOperations: syncStats['failed']!,
        pendingOperations: await _getPendingOperationsCount(),
        lastSyncTime: _lastSyncTime,
        syncDuration: syncDuration,
      );

      // Update total counters
      _totalSyncedTransactions += syncStats['transactions']!;
      _totalSyncedCategories += syncStats['categories']!;
      _totalFailedOperations += syncStats['failed']!;

      _updateSyncStatus(SyncStatus.success);
      _syncResultController.add(result);

      log('Force sync completed: ${syncStats['transactions']} transactions, ${syncStats['categories']} categories in ${syncDuration.inMilliseconds}ms',
          name: 'SyncService');

      return result;
    } catch (e) {
      log('Force sync failed: $e', name: 'SyncService');
      _updateSyncStatus(SyncStatus.error);

      final syncEndTime = DateTime.now();
      final syncDuration = syncEndTime.difference(syncStartTime);

      final syncStats = _bidirectionalSyncManager.syncSessionStats;
      final result = SyncResult(
        success: false,
        error: e.toString(),
        syncedTransactions: syncStats['transactions']!,
        syncedCategories: syncStats['categories']!,
        failedOperations: syncStats['failed']! + 1,
        pendingOperations: await _getPendingOperationsCount(),
        lastSyncTime: _lastSyncTime,
        syncDuration: syncDuration,
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
        'lastSyncTime': _lastSyncTime?.toIso8601String(),
        'totalSyncedTransactions': _totalSyncedTransactions,
        'totalSyncedCategories': _totalSyncedCategories,
        'totalFailedOperations': _totalFailedOperations,
        'currentSessionTransactions':
            _bidirectionalSyncManager.syncSessionStats['transactions'],
        'currentSessionCategories':
            _bidirectionalSyncManager.syncSessionStats['categories'],
        'currentSessionFailed':
            _bidirectionalSyncManager.syncSessionStats['failed'],
      };
    } catch (e) {
      log('Error getting sync stats: $e', name: 'SyncService');
      return {
        'isOnline': _connectivityService.isConnected,
        'currentStatus': _currentStatus.name,
        'pendingOperations': 0,
        'totalSyncedTransactions': _totalSyncedTransactions,
        'totalSyncedCategories': _totalSyncedCategories,
        'totalFailedOperations': _totalFailedOperations,
        'error': e.toString(),
      };
    }
  }

  /// Get error statistics
  Map<String, dynamic> get errorStats {
    return _syncErrorHandler.getErrorStats();
  }

  /// Force retry failed operations (manual recovery)
  Future<void> forceRetryFailedOperations() async {
    if (!_connectivityService.isConnected) {
      throw Exception('Cannot retry operations while offline');
    }

    log('Force retrying failed operations', name: 'SyncService');

    try {
      // Reset consecutive failures for fresh start
      _syncErrorHandler.resetConsecutiveFailures();

      // Attempt to sync pending operations
      await _syncPendingOperations();

      log('Force retry completed successfully', name: 'SyncService');
    } catch (e) {
      final syncError = _syncErrorHandler.categorizeError(e);
      _syncErrorHandler.handleSyncError(syncError);
      rethrow;
    }
  }

  /// Dispose of the sync service
  void dispose() {
    _stopRealTimeListeners();
    _connectivitySubscription?.cancel();
    _periodicSyncTimer?.cancel();
    _syncStatusController.close();
    _syncResultController.close();
    _connectivityStatusController.close();

    // Dispose extracted services
    _syncProgressManager.dispose();
    _syncErrorHandler.dispose();
    _conflictResolutionService.dispose();
    _objectPoolManager.clearPools();
  }
}
