import 'dart:async';
import 'dart:developer';
import 'dart:math' as math;
import 'package:money_track/core/error/failures.dart';
import 'sync_models.dart';

/// Handles sync error categorization, tracking, and retry logic
class SyncErrorHandler {
  // Error handling and tracking
  final List<SyncError> _recentErrors = [];
  final StreamController<SyncError> _errorController =
      StreamController<SyncError>.broadcast();
  final int _maxErrorHistory = 50;

  // Retry configuration
  int _consecutiveFailures = 0;
  final int _maxRetryAttempts = 5;
  final Duration _baseRetryDelay = const Duration(seconds: 30);
  Timer? _retryTimer;

  /// Stream of sync errors
  Stream<SyncError> get errorStream => _errorController.stream;

  /// Get recent sync errors
  List<SyncError> get recentErrors => List.unmodifiable(_recentErrors);

  /// Get consecutive failure count
  int get consecutiveFailures => _consecutiveFailures;

  /// Get max retry attempts
  int get maxRetryAttempts => _maxRetryAttempts;

  /// Clear error history
  void clearErrorHistory() {
    _recentErrors.clear();
    log('Cleared sync error history', name: 'SyncErrorHandler');
  }

  /// Reset consecutive failures counter
  void resetConsecutiveFailures() {
    _consecutiveFailures = 0;
    log('Reset consecutive failures counter', name: 'SyncErrorHandler');
  }

  /// Increment consecutive failures counter
  void incrementConsecutiveFailures() {
    _consecutiveFailures++;
    log('Incremented consecutive failures to $_consecutiveFailures',
        name: 'SyncErrorHandler');
  }

  /// Categorize an error based on its type and content
  SyncError categorizeError(dynamic error,
      {int retryCount = 0, String? operationId}) {
    SyncErrorType errorType;
    bool isRetryable = true;
    String message = error.toString();
    String? details;

    if (error is NetworkFailure) {
      errorType = SyncErrorType.networkError;
      isRetryable = true;
    } else if (error is DatabaseFailure) {
      errorType = SyncErrorType.dataCorruption;
      isRetryable = true;
    } else if (error.toString().contains('authentication') ||
        error.toString().contains('auth')) {
      errorType = SyncErrorType.authenticationError;
      isRetryable = false; // Don't retry auth errors automatically
    } else if (error.toString().contains('permission')) {
      errorType = SyncErrorType.permissionError;
      isRetryable = false;
    } else if (error.toString().contains('quota') ||
        error.toString().contains('limit')) {
      errorType = SyncErrorType.quotaExceeded;
      isRetryable = false;
    } else if (error.toString().contains('server') ||
        error.toString().contains('500') ||
        error.toString().contains('502') ||
        error.toString().contains('503')) {
      errorType = SyncErrorType.serverError;
      isRetryable = true;
    } else if (error.toString().contains('conflict')) {
      errorType = SyncErrorType.conflictError;
      isRetryable = true;
    } else {
      errorType = SyncErrorType.unknownError;
      isRetryable = true;
    }

    // Add more context for certain error types
    if (error is Failure) {
      details = error.message;
    }

    return SyncError(
      type: errorType,
      message: message,
      details: details,
      timestamp: DateTime.now(),
      isRetryable: isRetryable,
      retryCount: retryCount,
      operationId: operationId,
    );
  }

  /// Handle a sync error by logging and storing it
  void handleSyncError(SyncError syncError) {
    log('Sync error [${syncError.type.name}]: ${syncError.message}',
        name: 'SyncErrorHandler');

    // Add to recent errors list
    _recentErrors.add(syncError);

    // Maintain error history size
    if (_recentErrors.length > _maxErrorHistory) {
      _recentErrors.removeAt(0);
    }

    // Emit error to stream
    _errorController.add(syncError);
  }

  /// Calculate retry delay using exponential backoff
  Duration calculateRetryDelay() {
    // Exponential backoff with jitter: base * 2^failures + random(0, base)
    final exponentialDelay =
        _baseRetryDelay * math.pow(2, _consecutiveFailures);
    final jitter = Duration(
      milliseconds: math.Random().nextInt(_baseRetryDelay.inMilliseconds),
    );

    final totalDelay = exponentialDelay + jitter;

    // Cap at 10 minutes
    const maxDelay = Duration(minutes: 10);
    return totalDelay > maxDelay ? maxDelay : totalDelay;
  }

  /// Check if should retry based on error and attempt count
  bool shouldRetry(SyncError error) {
    return error.isRetryable && _consecutiveFailures < _maxRetryAttempts;
  }

  /// Schedule a retry operation
  void scheduleRetry(Future<void> Function() retryOperation) {
    _retryTimer?.cancel();

    if (_consecutiveFailures >= _maxRetryAttempts) {
      log('Max retry attempts reached ($_maxRetryAttempts), stopping retries',
          name: 'SyncErrorHandler');
      return;
    }

    final delay = calculateRetryDelay();
    log('Scheduling retry in ${delay.inSeconds} seconds (attempt ${_consecutiveFailures + 1}/$_maxRetryAttempts)',
        name: 'SyncErrorHandler');

    _retryTimer = Timer(delay, () async {
      try {
        await retryOperation();
        resetConsecutiveFailures(); // Reset on success
      } catch (e) {
        log('Retry operation failed: $e', name: 'SyncErrorHandler');

        final syncError = categorizeError(e, retryCount: _consecutiveFailures);
        handleSyncError(syncError);
        incrementConsecutiveFailures();

        // Schedule next retry if error is retryable
        if (shouldRetry(syncError)) {
          scheduleRetry(retryOperation);
        } else {
          log('Non-retryable error or max attempts reached, stopping retries',
              name: 'SyncErrorHandler');
        }
      }
    });
  }

  /// Cancel any pending retry
  void cancelRetry() {
    _retryTimer?.cancel();
    _retryTimer = null;
    log('Cancelled pending retry', name: 'SyncErrorHandler');
  }

  /// Get error statistics
  Map<String, dynamic> getErrorStats() {
    final errorsByType = <String, int>{};
    for (final error in _recentErrors) {
      final typeName = error.type.name;
      errorsByType[typeName] = (errorsByType[typeName] ?? 0) + 1;
    }

    return {
      'totalErrors': _recentErrors.length,
      'consecutiveFailures': _consecutiveFailures,
      'maxRetryAttempts': _maxRetryAttempts,
      'errorsByType': errorsByType,
      'hasActiveRetry': _retryTimer?.isActive ?? false,
      'nextRetryDelay': calculateRetryDelay().inSeconds,
    };
  }

  /// Dispose of resources
  void dispose() {
    _retryTimer?.cancel();
    _errorController.close();
    _recentErrors.clear();
  }
}
