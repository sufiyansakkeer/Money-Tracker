/// Enum for sync status
enum SyncStatus {
  idle,
  syncing,
  error,
  success,
}

/// Enum for conflict resolution strategies
enum ConflictResolutionStrategy {
  /// Last write wins based on timestamp
  lastWriteWins,

  /// Remote version always wins
  remoteWins,

  /// Local version always wins
  localWins,

  /// Higher version number wins
  versionBased,

  /// Manual resolution required (future implementation)
  manual,
}

/// Conflict resolution decision
enum ConflictResolution {
  useLocal,
  useRemote,
  requiresManualResolution,
  noConflict,
}

/// Sync error types for better error handling
enum SyncErrorType {
  networkError,
  authenticationError,
  permissionError,
  dataCorruption,
  conflictError,
  quotaExceeded,
  serverError,
  unknownError,
}

/// Conflict information for manual resolution
class ConflictInfo {
  final String id;
  final String dataType;
  final Map<String, dynamic> localData;
  final Map<String, dynamic> remoteData;
  final DateTime localUpdatedAt;
  final DateTime remoteUpdatedAt;
  final int localVersion;
  final int remoteVersion;

  const ConflictInfo({
    required this.id,
    required this.dataType,
    required this.localData,
    required this.remoteData,
    required this.localUpdatedAt,
    required this.remoteUpdatedAt,
    required this.localVersion,
    required this.remoteVersion,
  });
}

/// Detailed sync error information
class SyncError {
  final SyncErrorType type;
  final String message;
  final String? details;
  final DateTime timestamp;
  final bool isRetryable;
  final int retryCount;
  final String? operationId;

  const SyncError({
    required this.type,
    required this.message,
    this.details,
    required this.timestamp,
    this.isRetryable = true,
    this.retryCount = 0,
    this.operationId,
  });

  SyncError copyWith({
    SyncErrorType? type,
    String? message,
    String? details,
    DateTime? timestamp,
    bool? isRetryable,
    int? retryCount,
    String? operationId,
  }) {
    return SyncError(
      type: type ?? this.type,
      message: message ?? this.message,
      details: details ?? this.details,
      timestamp: timestamp ?? this.timestamp,
      isRetryable: isRetryable ?? this.isRetryable,
      retryCount: retryCount ?? this.retryCount,
      operationId: operationId ?? this.operationId,
    );
  }
}

/// Bidirectional sync result for individual items
class BidirectionalSyncResult {
  final bool localUpdated;
  final bool remoteUpdated;
  final String? error;

  const BidirectionalSyncResult({
    this.localUpdated = false,
    this.remoteUpdated = false,
    this.error,
  });
}

/// Sync progress information
class SyncProgress {
  final String currentOperation;
  final int totalItems;
  final int processedItems;
  final double progressPercentage;
  final String? currentItemId;

  const SyncProgress({
    required this.currentOperation,
    required this.totalItems,
    required this.processedItems,
    this.currentItemId,
  }) : progressPercentage =
            totalItems > 0 ? (processedItems / totalItems) * 100 : 0;

  SyncProgress copyWith({
    String? currentOperation,
    int? totalItems,
    int? processedItems,
    String? currentItemId,
  }) {
    return SyncProgress(
      currentOperation: currentOperation ?? this.currentOperation,
      totalItems: totalItems ?? this.totalItems,
      processedItems: processedItems ?? this.processedItems,
      currentItemId: currentItemId ?? this.currentItemId,
    );
  }
}

/// Sync result information
class SyncResult {
  final bool success;
  final String? error;
  final int syncedTransactions;
  final int syncedCategories;
  final int pendingOperations;
  final int failedOperations;
  final DateTime? lastSyncTime;
  final Duration? syncDuration;
  final SyncProgress? progress;
  final Map<String, dynamic>? additionalInfo;

  const SyncResult({
    required this.success,
    this.error,
    this.syncedTransactions = 0,
    this.syncedCategories = 0,
    this.pendingOperations = 0,
    this.failedOperations = 0,
    this.lastSyncTime,
    this.syncDuration,
    this.progress,
    this.additionalInfo,
  });

  /// Create a copy with updated values
  SyncResult copyWith({
    bool? success,
    String? error,
    int? syncedTransactions,
    int? syncedCategories,
    int? pendingOperations,
    int? failedOperations,
    DateTime? lastSyncTime,
    Duration? syncDuration,
    SyncProgress? progress,
    Map<String, dynamic>? additionalInfo,
  }) {
    return SyncResult(
      success: success ?? this.success,
      error: error ?? this.error,
      syncedTransactions: syncedTransactions ?? this.syncedTransactions,
      syncedCategories: syncedCategories ?? this.syncedCategories,
      pendingOperations: pendingOperations ?? this.pendingOperations,
      failedOperations: failedOperations ?? this.failedOperations,
      lastSyncTime: lastSyncTime ?? this.lastSyncTime,
      syncDuration: syncDuration ?? this.syncDuration,
      progress: progress ?? this.progress,
      additionalInfo: additionalInfo ?? this.additionalInfo,
    );
  }
}
