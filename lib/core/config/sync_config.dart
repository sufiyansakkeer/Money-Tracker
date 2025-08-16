/// Configuration settings for the sync system
class SyncConfig {
  /// Maximum number of retry attempts for sync operations
  static const int maxRetryAttempts = 3;

  /// Timeout duration for network requests
  static const Duration networkTimeout = Duration(seconds: 30);

  /// Interval for periodic sync checks
  static const Duration periodicSyncInterval = Duration(minutes: 5);

  /// Maximum number of pending operations to keep in queue
  static const int maxPendingOperations = 1000;

  /// Batch size for bulk sync operations
  static const int syncBatchSize = 50;

  /// Timeout for waiting for internet connection
  static const Duration connectionTimeout = Duration(seconds: 30);

  /// Delay before retrying failed operations
  static const Duration retryDelay = Duration(seconds: 5);

  /// Maximum age for cached data before forcing refresh
  static const Duration maxCacheAge = Duration(hours: 24);

  /// Enable/disable real-time listeners
  static const bool enableRealTimeSync = true;

  /// Enable/disable offline mode
  static const bool enableOfflineMode = true;

  /// Enable/disable automatic sync on app startup
  static const bool enableAutoSyncOnStartup = true;

  /// Enable/disable sync on network reconnection
  static const bool enableSyncOnReconnection = true;

  /// Minimum time between sync operations to prevent spam
  static const Duration minSyncInterval = Duration(seconds: 10);

  /// Maximum time to wait for sync completion
  static const Duration maxSyncDuration = Duration(minutes: 10);

  /// Enable/disable conflict resolution
  static const bool enableConflictResolution = true;

  /// Conflict resolution strategy
  static const ConflictResolutionStrategy conflictResolutionStrategy = 
      ConflictResolutionStrategy.lastWriteWins;

  /// Enable/disable sync analytics and logging
  static const bool enableSyncLogging = true;

  /// Log level for sync operations
  static const SyncLogLevel logLevel = SyncLogLevel.info;

  /// Firebase collection names
  static const String transactionsCollection = 'transactions';
  static const String categoriesCollection = 'categories';
  static const String usersCollection = 'users';

  /// Local database names
  static const String syncOperationsBox = 'sync-operations';
  static const String syncMetadataBox = 'sync-metadata';

  /// Sync operation priorities
  static const Map<String, int> operationPriorities = {
    'create': 1,
    'update': 2,
    'delete': 3,
  };

  /// Data validation settings
  static const bool enableDataValidation = true;
  static const bool enableSchemaValidation = true;

  /// Performance settings
  static const bool enableBatchOperations = true;
  static const bool enableCompression = false; // For future use
  static const bool enableCaching = true;

  /// Security settings
  static const bool enableEncryption = false; // For future use
  static const bool enableDataIntegrityChecks = true;

  /// Feature flags
  static const bool enableBidirectionalSync = true;
  static const bool enableIncrementalSync = true;
  static const bool enableDeltaSync = false; // For future use

  /// Error handling settings
  static const bool enableAutomaticErrorRecovery = true;
  static const bool enableErrorReporting = true;
  static const Duration errorReportingThrottle = Duration(minutes: 5);

  /// Development/Debug settings
  static const bool enableDebugMode = false;
  static const bool enableVerboseLogging = false;
  static const bool enableSyncSimulation = false;
}

/// Conflict resolution strategies
enum ConflictResolutionStrategy {
  /// Last write wins (timestamp-based)
  lastWriteWins,
  
  /// First write wins
  firstWriteWins,
  
  /// Version-based resolution
  versionBased,
  
  /// Manual resolution (present to user)
  manual,
  
  /// Merge changes (for future use)
  merge,
}

/// Sync log levels
enum SyncLogLevel {
  /// Only log errors
  error,
  
  /// Log warnings and errors
  warning,
  
  /// Log info, warnings, and errors
  info,
  
  /// Log everything including debug info
  debug,
  
  /// Log everything with verbose details
  verbose,
}

/// Sync operation types
enum SyncOperationType {
  /// Full sync (all data)
  full,
  
  /// Incremental sync (only changes)
  incremental,
  
  /// Delta sync (minimal changes)
  delta,
  
  /// Manual sync (user-triggered)
  manual,
  
  /// Automatic sync (system-triggered)
  automatic,
}

/// Sync status types
enum SyncStatusType {
  /// Sync is idle
  idle,
  
  /// Sync is in progress
  syncing,
  
  /// Sync completed successfully
  success,
  
  /// Sync failed with error
  error,
  
  /// Device is offline
  offline,
  
  /// Sync is paused
  paused,
}

/// Network connection types
enum NetworkConnectionType {
  /// No connection
  none,
  
  /// WiFi connection
  wifi,
  
  /// Mobile data connection
  mobile,
  
  /// Ethernet connection
  ethernet,
  
  /// VPN connection
  vpn,
  
  /// Other connection type
  other,
}

/// Data sync priorities
enum SyncPriority {
  /// Low priority (background sync)
  low,
  
  /// Normal priority (default)
  normal,
  
  /// High priority (user-initiated)
  high,
  
  /// Critical priority (immediate sync required)
  critical,
}

/// Sync configuration extensions for easy access
extension SyncConfigExtensions on SyncConfig {
  /// Get retry delay with exponential backoff
  static Duration getRetryDelay(int attemptNumber) {
    final baseDelay = SyncConfig.retryDelay;
    final exponentialDelay = Duration(
      milliseconds: baseDelay.inMilliseconds * (1 << (attemptNumber - 1)),
    );
    
    // Cap at maximum delay
    const maxDelay = Duration(minutes: 5);
    return exponentialDelay > maxDelay ? maxDelay : exponentialDelay;
  }

  /// Check if operation should be retried
  static bool shouldRetry(int attemptNumber, Exception error) {
    if (attemptNumber >= SyncConfig.maxRetryAttempts) {
      return false;
    }
    
    // Add logic to determine if error is retryable
    return true; // Simplified for now
  }

  /// Get sync interval based on network type
  static Duration getSyncInterval(NetworkConnectionType connectionType) {
    switch (connectionType) {
      case NetworkConnectionType.wifi:
        return const Duration(minutes: 2);
      case NetworkConnectionType.mobile:
        return const Duration(minutes: 10);
      case NetworkConnectionType.none:
        return Duration.zero;
      default:
        return SyncConfig.periodicSyncInterval;
    }
  }
}
