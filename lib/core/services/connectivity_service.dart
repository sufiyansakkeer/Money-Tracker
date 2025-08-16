import 'dart:async';
import 'dart:developer';
import 'package:connectivity_plus/connectivity_plus.dart';

/// Service to monitor network connectivity status
class ConnectivityService {
  final Connectivity _connectivity;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  
  // Stream controller for connectivity status
  final StreamController<bool> _connectivityController = StreamController<bool>.broadcast();
  
  bool _isConnected = false;
  
  ConnectivityService({required Connectivity connectivity}) : _connectivity = connectivity;

  /// Get current connectivity status
  bool get isConnected => _isConnected;

  /// Stream of connectivity status changes
  Stream<bool> get connectivityStream => _connectivityController.stream;

  /// Initialize the connectivity service
  Future<void> initialize() async {
    try {
      // Check initial connectivity status
      final connectivityResults = await _connectivity.checkConnectivity();
      _updateConnectivityStatus(connectivityResults);

      // Listen to connectivity changes
      _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
        _updateConnectivityStatus,
        onError: (error) {
          log('Connectivity stream error: $error', name: 'ConnectivityService');
        },
      );
    } catch (e) {
      log('Failed to initialize connectivity service: $e', name: 'ConnectivityService');
      // Assume connected if we can't determine connectivity
      _isConnected = true;
      _connectivityController.add(_isConnected);
    }
  }

  /// Update connectivity status based on connectivity results
  void _updateConnectivityStatus(List<ConnectivityResult> connectivityResults) {
    final wasConnected = _isConnected;
    
    // Check if any of the connectivity results indicate a connection
    _isConnected = connectivityResults.any((result) => 
      result == ConnectivityResult.mobile ||
      result == ConnectivityResult.wifi ||
      result == ConnectivityResult.ethernet ||
      result == ConnectivityResult.vpn ||
      result == ConnectivityResult.bluetooth ||
      result == ConnectivityResult.other
    );

    // Only emit if status changed
    if (wasConnected != _isConnected) {
      log('Connectivity changed: ${_isConnected ? "Connected" : "Disconnected"}', 
          name: 'ConnectivityService');
      _connectivityController.add(_isConnected);
    }
  }

  /// Wait for internet connection
  Future<void> waitForConnection({Duration timeout = const Duration(seconds: 30)}) async {
    if (_isConnected) return;

    final completer = Completer<void>();
    late StreamSubscription<bool> subscription;

    // Set up timeout
    final timeoutTimer = Timer(timeout, () {
      if (!completer.isCompleted) {
        subscription.cancel();
        completer.completeError(TimeoutException('Connection timeout', timeout));
      }
    });

    // Listen for connection
    subscription = connectivityStream.listen((isConnected) {
      if (isConnected && !completer.isCompleted) {
        timeoutTimer.cancel();
        subscription.cancel();
        completer.complete();
      }
    });

    return completer.future;
  }

  /// Check if device has internet connectivity (more thorough check)
  Future<bool> hasInternetConnection() async {
    try {
      final connectivityResults = await _connectivity.checkConnectivity();
      
      // If no connectivity result indicates connection, return false
      if (!connectivityResults.any((result) => 
        result == ConnectivityResult.mobile ||
        result == ConnectivityResult.wifi ||
        result == ConnectivityResult.ethernet ||
        result == ConnectivityResult.vpn ||
        result == ConnectivityResult.bluetooth ||
        result == ConnectivityResult.other
      )) {
        return false;
      }

      // For a more thorough check, you could ping a reliable server
      // For now, we'll trust the connectivity result
      return true;
    } catch (e) {
      log('Error checking internet connection: $e', name: 'ConnectivityService');
      return false;
    }
  }

  /// Dispose of the service
  void dispose() {
    _connectivitySubscription?.cancel();
    _connectivityController.close();
  }
}

/// Exception thrown when waiting for connection times out
class TimeoutException implements Exception {
  final String message;
  final Duration timeout;

  const TimeoutException(this.message, this.timeout);

  @override
  String toString() => 'TimeoutException: $message (timeout: ${timeout.inSeconds}s)';
}
