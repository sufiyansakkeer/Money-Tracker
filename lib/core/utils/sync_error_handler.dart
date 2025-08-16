import 'dart:developer';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:money_track/core/error/failures.dart';

/// Comprehensive error handler for sync operations
class SyncErrorHandler {
  /// Handle Firebase Auth errors
  static Failure handleAuthError(FirebaseAuthException error) {
    log('Firebase Auth Error: ${error.code} - ${error.message}',
        name: 'SyncErrorHandler');

    switch (error.code) {
      case 'user-not-found':
        return AuthFailure(message: 'User account not found. Please sign up.');
      case 'wrong-password':
        return AuthFailure(message: 'Incorrect password. Please try again.');
      case 'user-disabled':
        return AuthFailure(message: 'This account has been disabled.');
      case 'too-many-requests':
        return AuthFailure(
            message: 'Too many failed attempts. Please try again later.');
      case 'network-request-failed':
        return NetworkFailure(
            message: 'Network error. Please check your connection.');
      case 'email-already-in-use':
        return AuthFailure(
            message: 'An account with this email already exists.');
      case 'weak-password':
        return AuthFailure(
            message:
                'Password is too weak. Please choose a stronger password.');
      case 'invalid-email':
        return AuthFailure(message: 'Invalid email address format.');
      case 'operation-not-allowed':
        return AuthFailure(message: 'This operation is not allowed.');
      case 'requires-recent-login':
        return AuthFailure(
            message: 'Please sign in again to complete this action.');
      default:
        return AuthFailure(message: 'Authentication failed: ${error.message}');
    }
  }

  /// Handle Firestore errors
  static Failure handleFirestoreError(FirebaseException error) {
    log('Firestore Error: ${error.code} - ${error.message}',
        name: 'SyncErrorHandler');

    switch (error.code) {
      case 'permission-denied':
        return NetworkFailure(
            message: 'Access denied. Please check your permissions.');
      case 'not-found':
        return NetworkFailure(message: 'Requested data not found.');
      case 'already-exists':
        return NetworkFailure(message: 'Data already exists.');
      case 'resource-exhausted':
        return NetworkFailure(
            message:
                'Service temporarily unavailable. Please try again later.');
      case 'failed-precondition':
        return NetworkFailure(
            message: 'Operation failed due to conflicting data.');
      case 'aborted':
        return NetworkFailure(
            message: 'Operation was aborted due to a conflict.');
      case 'out-of-range':
        return NetworkFailure(message: 'Invalid data range.');
      case 'unimplemented':
        return NetworkFailure(message: 'This feature is not yet available.');
      case 'internal':
        return NetworkFailure(
            message: 'Internal server error. Please try again.');
      case 'unavailable':
        return NetworkFailure(message: 'Service temporarily unavailable.');
      case 'data-loss':
        return NetworkFailure(
            message: 'Data corruption detected. Please contact support.');
      case 'unauthenticated':
        return AuthFailure(message: 'Authentication required. Please sign in.');
      case 'deadline-exceeded':
        return NetworkFailure(message: 'Request timeout. Please try again.');
      case 'cancelled':
        return NetworkFailure(message: 'Operation was cancelled.');
      default:
        return NetworkFailure(message: 'Sync failed: ${error.message}');
    }
  }

  /// Handle general sync errors
  static Failure handleSyncError(dynamic error) {
    log('Sync Error: $error', name: 'SyncErrorHandler');

    if (error is FirebaseAuthException) {
      return handleAuthError(error);
    } else if (error is FirebaseException) {
      return handleFirestoreError(error);
    } else if (error is NetworkFailure) {
      return error;
    } else if (error is AuthFailure) {
      return error;
    } else if (error is DatabaseFailure) {
      return error;
    } else {
      return NetworkFailure(
          message: 'Unexpected sync error: ${error.toString()}');
    }
  }

  /// Check if error is retryable
  static bool isRetryableError(Failure error) {
    if (error is NetworkFailure) {
      final message = error.message.toLowerCase();
      return message.contains('network') ||
          message.contains('timeout') ||
          message.contains('unavailable') ||
          message.contains('internal') ||
          message.contains('cancelled');
    }
    return false;
  }

  /// Get user-friendly error message
  static String getUserFriendlyMessage(Failure error) {
    if (error is AuthFailure) {
      return error.message;
    } else if (error is NetworkFailure) {
      final message = error.message.toLowerCase();
      if (message.contains('network') || message.contains('connection')) {
        return 'Please check your internet connection and try again.';
      } else if (message.contains('timeout')) {
        return 'Request timed out. Please try again.';
      } else if (message.contains('unavailable')) {
        return 'Service is temporarily unavailable. Please try again later.';
      } else if (message.contains('permission')) {
        return 'You don\'t have permission to perform this action.';
      } else {
        return 'Sync failed. Please try again.';
      }
    } else if (error is DatabaseFailure) {
      return 'Local database error. Please restart the app.';
    } else {
      return 'An unexpected error occurred. Please try again.';
    }
  }

  /// Get retry delay based on error type and attempt count
  static Duration getRetryDelay(Failure error, int attemptCount) {
    // Exponential backoff with jitter
    final baseDelay = Duration(seconds: 2 * (1 << (attemptCount - 1)));
    final maxDelay = const Duration(minutes: 5);

    if (error is NetworkFailure) {
      final message = error.message.toLowerCase();
      if (message.contains('rate') || message.contains('too many')) {
        // Rate limiting - longer delay
        return Duration(minutes: attemptCount * 2);
      } else if (message.contains('unavailable')) {
        // Service unavailable - moderate delay
        return Duration(seconds: 30 * attemptCount);
      }
    }

    // Default exponential backoff
    return baseDelay.compareTo(maxDelay) > 0 ? maxDelay : baseDelay;
  }

  /// Log error with context
  static void logError(String operation, Failure error,
      {Map<String, dynamic>? context}) {
    final contextStr = context != null ? ' Context: $context' : '';
    log('$operation failed: ${error.toString()}$contextStr',
        name: 'SyncErrorHandler', level: 1000); // Error level
  }

  /// Log warning with context
  static void logWarning(String operation, String message,
      {Map<String, dynamic>? context}) {
    final contextStr = context != null ? ' Context: $context' : '';
    log('$operation warning: $message$contextStr',
        name: 'SyncErrorHandler', level: 900); // Warning level
  }

  /// Log info with context
  static void logInfo(String operation, String message,
      {Map<String, dynamic>? context}) {
    final contextStr = context != null ? ' Context: $context' : '';
    log('$operation: $message$contextStr',
        name: 'SyncErrorHandler', level: 800); // Info level
  }
}

/// Extension for easier error handling in sync operations
extension SyncErrorHandling on Future {
  /// Handle sync errors with automatic retry logic
  Future<T> handleSyncError<T>(String operation, {int maxRetries = 3}) async {
    int attempts = 0;
    Failure? lastError;

    while (attempts < maxRetries) {
      attempts++;
      try {
        return await this as T;
      } catch (error) {
        lastError = SyncErrorHandler.handleSyncError(error);

        SyncErrorHandler.logError(operation, lastError, context: {
          'attempt': attempts,
          'maxRetries': maxRetries,
        });

        if (attempts >= maxRetries ||
            !SyncErrorHandler.isRetryableError(lastError)) {
          break;
        }

        // Wait before retrying
        final delay = SyncErrorHandler.getRetryDelay(lastError, attempts);
        SyncErrorHandler.logInfo(
            operation, 'Retrying in ${delay.inSeconds} seconds');
        await Future.delayed(delay);
      }
    }

    throw lastError ?? NetworkFailure(message: 'Unknown error in $operation');
  }
}
