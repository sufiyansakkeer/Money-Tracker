import 'dart:async';
import 'dart:developer';
import 'sync_models.dart';

/// Manages sync progress tracking and reporting
class SyncProgressManager {
  // Progress tracking
  SyncProgress? _currentProgress;
  final StreamController<SyncProgress> _progressController =
      StreamController<SyncProgress>.broadcast();

  // Performance optimization constants
  static const int _yieldInterval = 5; // Yield to UI thread every N items
  static const Duration _progressUpdateThrottle =
      Duration(milliseconds: 100); // Throttle progress updates
  DateTime _lastProgressUpdate = DateTime.now();

  /// Stream of sync progress updates
  Stream<SyncProgress> get progressStream => _progressController.stream;

  /// Current sync progress
  SyncProgress? get currentProgress => _currentProgress;

  /// Update sync progress with throttling
  void updateProgress(String operation, int totalItems, int processedItems,
      {String? currentItemId}) {
    final now = DateTime.now();
    
    // Throttle progress updates to avoid overwhelming the UI
    if (now.difference(_lastProgressUpdate) < _progressUpdateThrottle) {
      return;
    }

    _currentProgress = SyncProgress(
      currentOperation: operation,
      totalItems: totalItems,
      processedItems: processedItems,
      currentItemId: currentItemId,
    );

    _progressController.add(_currentProgress!);
    _lastProgressUpdate = now;

    log('Progress: $operation - $processedItems/$totalItems (${_currentProgress!.progressPercentage.toStringAsFixed(1)}%)',
        name: 'SyncProgressManager');
  }

  /// Clear current progress
  void clearProgress() {
    _currentProgress = null;
    log('Progress cleared', name: 'SyncProgressManager');
  }

  /// Process items in batches with progress updates and UI yielding
  Future<void> processBatch<T>(
    List<T> items,
    String operationName,
    Future<void> Function(T item, int index) processor,
  ) async {
    final totalItems = items.length;
    
    if (totalItems == 0) {
      log('No items to process for: $operationName', name: 'SyncProgressManager');
      return;
    }

    log('Starting batch processing: $operationName ($totalItems items)',
        name: 'SyncProgressManager');

    for (int i = 0; i < totalItems; i++) {
      try {
        await processor(items[i], i);

        // Update progress
        updateProgress(operationName, totalItems, i + 1);

        // Yield to UI thread periodically to prevent blocking
        if ((i + 1) % _yieldInterval == 0) {
          await Future.delayed(Duration.zero);
        }
      } catch (e) {
        log('Error processing item ${i + 1}/$totalItems in $operationName: $e',
            name: 'SyncProgressManager');
        rethrow;
      }
    }

    log('Completed batch processing: $operationName', name: 'SyncProgressManager');
  }

  /// Get progress statistics
  Map<String, dynamic> getProgressStats() {
    return {
      'hasCurrentProgress': _currentProgress != null,
      'currentOperation': _currentProgress?.currentOperation,
      'progressPercentage': _currentProgress?.progressPercentage,
      'totalItems': _currentProgress?.totalItems,
      'processedItems': _currentProgress?.processedItems,
      'lastProgressUpdate': _lastProgressUpdate.toIso8601String(),
    };
  }

  /// Dispose of resources
  void dispose() {
    _progressController.close();
    clearProgress();
  }
}
