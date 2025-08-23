import 'dart:async';
import 'dart:developer';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:money_track/core/services/connectivity_service.dart';
import 'package:money_track/core/services/sync_service.dart';
import 'package:money_track/core/services/sync/sync_models.dart';

/// Sync state
abstract class SyncState extends Equatable {
  const SyncState();

  @override
  List<Object?> get props => [];
}

/// Initial sync state
class SyncInitial extends SyncState {}

/// Sync is idle (not actively syncing)
class SyncIdle extends SyncState {
  final bool isOnline;
  final int pendingOperations;

  const SyncIdle({
    required this.isOnline,
    this.pendingOperations = 0,
  });

  @override
  List<Object?> get props => [isOnline, pendingOperations];
}

/// Sync is in progress
class SyncInProgress extends SyncState {
  final String? message;

  const SyncInProgress({this.message});

  @override
  List<Object?> get props => [message];
}

/// Sync completed successfully
class SyncSuccess extends SyncState {
  final int syncedTransactions;
  final int syncedCategories;
  final DateTime timestamp;

  const SyncSuccess({
    this.syncedTransactions = 0,
    this.syncedCategories = 0,
    required this.timestamp,
  });

  @override
  List<Object?> get props => [syncedTransactions, syncedCategories, timestamp];
}

/// Sync failed with error
class SyncError extends SyncState {
  final String message;
  final bool isOnline;
  final int pendingOperations;

  const SyncError({
    required this.message,
    required this.isOnline,
    this.pendingOperations = 0,
  });

  @override
  List<Object?> get props => [message, isOnline, pendingOperations];
}

/// Offline state with pending operations
class SyncOffline extends SyncState {
  final int pendingOperations;

  const SyncOffline({this.pendingOperations = 0});

  @override
  List<Object?> get props => [pendingOperations];
}

/// Cubit for managing sync state
class SyncCubit extends Cubit<SyncState> {
  final SyncService _syncService;
  final ConnectivityService _connectivityService;

  StreamSubscription<SyncStatus>? _syncStatusSubscription;
  StreamSubscription<SyncResult>? _syncResultSubscription;
  StreamSubscription<bool>? _connectivitySubscription;

  SyncCubit({
    required SyncService syncService,
    required ConnectivityService connectivityService,
  })  : _syncService = syncService,
        _connectivityService = connectivityService,
        super(SyncInitial()) {
    _initializeListeners();
  }

  /// Initialize listeners for sync and connectivity changes
  void _initializeListeners() {
    // Listen to sync status changes
    _syncStatusSubscription = _syncService.syncStatusStream.listen(
      _onSyncStatusChanged,
      onError: (error) {
        log('Sync status stream error: $error', name: 'SyncCubit');
      },
    );

    // Listen to sync results
    _syncResultSubscription = _syncService.syncResultStream.listen(
      _onSyncResultChanged,
      onError: (error) {
        log('Sync result stream error: $error', name: 'SyncCubit');
      },
    );

    // Listen to connectivity changes
    _connectivitySubscription = _connectivityService.connectivityStream.listen(
      _onConnectivityChanged,
      onError: (error) {
        log('Connectivity stream error: $error', name: 'SyncCubit');
      },
    );

    // Initialize with current state
    _updateStateFromCurrentStatus();
  }

  /// Handle sync status changes
  void _onSyncStatusChanged(SyncStatus status) async {
    switch (status) {
      case SyncStatus.idle:
        final stats = await _syncService.getSyncStats();
        emit(SyncIdle(
          isOnline: _connectivityService.isConnected,
          pendingOperations: stats['pendingOperations'] ?? 0,
        ));
        break;
      case SyncStatus.syncing:
        emit(const SyncInProgress(message: 'Syncing data...'));
        break;
      case SyncStatus.success:
        // Will be handled by sync result
        break;
      case SyncStatus.error:
        // Will be handled by sync result
        break;
    }
  }

  /// Handle sync result changes
  void _onSyncResultChanged(SyncResult result) async {
    if (result.success) {
      emit(SyncSuccess(
        syncedTransactions: result.syncedTransactions,
        syncedCategories: result.syncedCategories,
        timestamp: DateTime.now(),
      ));
    } else {
      final stats = await _syncService.getSyncStats();
      emit(SyncError(
        message: result.error ?? 'Sync failed',
        isOnline: _connectivityService.isConnected,
        pendingOperations: stats['pendingOperations'] ?? 0,
      ));
    }
  }

  /// Handle connectivity changes
  void _onConnectivityChanged(bool isConnected) async {
    if (!isConnected) {
      final stats = await _syncService.getSyncStats();
      emit(SyncOffline(pendingOperations: stats['pendingOperations'] ?? 0));
    } else {
      // When back online, update to idle state
      final stats = await _syncService.getSyncStats();
      emit(SyncIdle(
        isOnline: true,
        pendingOperations: stats['pendingOperations'] ?? 0,
      ));
    }
  }

  /// Update state from current sync service status
  void _updateStateFromCurrentStatus() async {
    try {
      final stats = await _syncService.getSyncStats();
      final isOnline = _connectivityService.isConnected;
      final pendingOps = stats['pendingOperations'] ?? 0;

      if (!isOnline) {
        emit(SyncOffline(pendingOperations: pendingOps));
      } else {
        switch (_syncService.currentStatus) {
          case SyncStatus.idle:
            emit(SyncIdle(isOnline: isOnline, pendingOperations: pendingOps));
            break;
          case SyncStatus.syncing:
            emit(const SyncInProgress());
            break;
          case SyncStatus.success:
            emit(SyncSuccess(timestamp: DateTime.now()));
            break;
          case SyncStatus.error:
            emit(SyncError(
              message: 'Sync error occurred',
              isOnline: isOnline,
              pendingOperations: pendingOps,
            ));
            break;
        }
      }
    } catch (e) {
      log('Error updating sync state: $e', name: 'SyncCubit');
      emit(SyncError(
        message: 'Failed to get sync status',
        isOnline: _connectivityService.isConnected,
      ));
    }
  }

  /// Force sync manually
  Future<void> forceSync() async {
    try {
      emit(const SyncInProgress(message: 'Manual sync in progress...'));
      await _syncService.forceSyncNow();
    } catch (e) {
      log('Error forcing sync: $e', name: 'SyncCubit');
      emit(SyncError(
        message: 'Manual sync failed: ${e.toString()}',
        isOnline: _connectivityService.isConnected,
      ));
    }
  }

  /// Get current sync statistics
  Future<Map<String, dynamic>> getSyncStats() async {
    return await _syncService.getSyncStats();
  }

  /// Check if there are pending operations
  Future<bool> hasPendingOperations() async {
    final stats = await _syncService.getSyncStats();
    return (stats['pendingOperations'] ?? 0) > 0;
  }

  /// Get connectivity status
  bool get isOnline => _connectivityService.isConnected;

  @override
  Future<void> close() {
    _syncStatusSubscription?.cancel();
    _syncResultSubscription?.cancel();
    _connectivitySubscription?.cancel();
    return super.close();
  }
}
