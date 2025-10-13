import 'dart:async';
import 'dart:developer';

/// Circuit breaker states
enum CircuitBreakerState {
  closed,    // Normal operation
  open,      // Failing fast, not executing operations
  halfOpen,  // Testing if service has recovered
}

/// Circuit breaker pattern implementation to prevent cascading failures
class CircuitBreaker {
  final String name;
  final int failureThreshold;
  final Duration timeout;
  final Duration resetTimeout;
  
  CircuitBreakerState _state = CircuitBreakerState.closed;
  int _failureCount = 0;
  DateTime? _lastFailureTime;
  Timer? _resetTimer;

  CircuitBreaker({
    required this.name,
    this.failureThreshold = 5,
    this.timeout = const Duration(seconds: 30),
    this.resetTimeout = const Duration(minutes: 1),
  });

  /// Get current state
  CircuitBreakerState get state => _state;

  /// Get current failure count
  int get failureCount => _failureCount;

  /// Execute operation with circuit breaker protection
  Future<T> execute<T>(Future<T> Function() operation) async {
    if (_state == CircuitBreakerState.open) {
      if (_shouldAttemptReset()) {
        _state = CircuitBreakerState.halfOpen;
        log('Circuit breaker $name transitioning to half-open state', 
            name: 'CircuitBreaker');
      } else {
        throw CircuitBreakerOpenException(
          'Circuit breaker $name is open. Last failure: $_lastFailureTime'
        );
      }
    }

    try {
      final result = await operation().timeout(timeout);
      _onSuccess();
      return result;
    } catch (e) {
      _onFailure();
      rethrow;
    }
  }

  /// Check if operation should be allowed
  bool get canExecute => _state != CircuitBreakerState.open || _shouldAttemptReset();

  /// Handle successful operation
  void _onSuccess() {
    _failureCount = 0;
    _lastFailureTime = null;
    _resetTimer?.cancel();
    
    if (_state == CircuitBreakerState.halfOpen) {
      _state = CircuitBreakerState.closed;
      log('Circuit breaker $name closed after successful operation', 
          name: 'CircuitBreaker');
    }
  }

  /// Handle failed operation
  void _onFailure() {
    _failureCount++;
    _lastFailureTime = DateTime.now();
    
    if (_failureCount >= failureThreshold) {
      _state = CircuitBreakerState.open;
      log('Circuit breaker $name opened after $_failureCount failures', 
          name: 'CircuitBreaker');
      
      // Schedule reset attempt
      _resetTimer = Timer(resetTimeout, () {
        log('Circuit breaker $name reset timer expired', name: 'CircuitBreaker');
      });
    }
  }

  /// Check if should attempt reset
  bool _shouldAttemptReset() {
    if (_lastFailureTime == null) return false;
    return DateTime.now().difference(_lastFailureTime!) >= resetTimeout;
  }

  /// Force reset the circuit breaker
  void reset() {
    _state = CircuitBreakerState.closed;
    _failureCount = 0;
    _lastFailureTime = null;
    _resetTimer?.cancel();
    log('Circuit breaker $name manually reset', name: 'CircuitBreaker');
  }

  /// Get circuit breaker status
  Map<String, dynamic> getStatus() {
    return {
      'name': name,
      'state': _state.toString(),
      'failureCount': _failureCount,
      'failureThreshold': failureThreshold,
      'lastFailureTime': _lastFailureTime?.toIso8601String(),
      'canExecute': canExecute,
    };
  }
}

/// Exception thrown when circuit breaker is open
class CircuitBreakerOpenException implements Exception {
  final String message;
  
  CircuitBreakerOpenException(this.message);
  
  @override
  String toString() => 'CircuitBreakerOpenException: $message';
}

/// Circuit breaker manager for multiple operations
class CircuitBreakerManager {
  final Map<String, CircuitBreaker> _circuitBreakers = {};

  /// Get or create circuit breaker for operation
  CircuitBreaker getCircuitBreaker(
    String operationName, {
    int failureThreshold = 5,
    Duration timeout = const Duration(seconds: 30),
    Duration resetTimeout = const Duration(minutes: 1),
  }) {
    return _circuitBreakers.putIfAbsent(
      operationName,
      () => CircuitBreaker(
        name: operationName,
        failureThreshold: failureThreshold,
        timeout: timeout,
        resetTimeout: resetTimeout,
      ),
    );
  }

  /// Execute operation with circuit breaker protection
  Future<T> execute<T>(
    String operationName,
    Future<T> Function() operation, {
    int failureThreshold = 5,
    Duration timeout = const Duration(seconds: 30),
    Duration resetTimeout = const Duration(minutes: 1),
  }) async {
    final circuitBreaker = getCircuitBreaker(
      operationName,
      failureThreshold: failureThreshold,
      timeout: timeout,
      resetTimeout: resetTimeout,
    );

    return circuitBreaker.execute(operation);
  }

  /// Check if operation can be executed
  bool canExecute(String operationName) {
    final circuitBreaker = _circuitBreakers[operationName];
    return circuitBreaker?.canExecute ?? true;
  }

  /// Reset specific circuit breaker
  void resetCircuitBreaker(String operationName) {
    _circuitBreakers[operationName]?.reset();
  }

  /// Reset all circuit breakers
  void resetAll() {
    for (final circuitBreaker in _circuitBreakers.values) {
      circuitBreaker.reset();
    }
    log('All circuit breakers reset', name: 'CircuitBreakerManager');
  }

  /// Get status of all circuit breakers
  Map<String, dynamic> getAllStatus() {
    return {
      'circuitBreakers': _circuitBreakers.values
          .map((cb) => cb.getStatus())
          .toList(),
      'totalCount': _circuitBreakers.length,
    };
  }

  /// Get circuit breakers that are currently open
  List<String> getOpenCircuitBreakers() {
    return _circuitBreakers.entries
        .where((entry) => entry.value.state == CircuitBreakerState.open)
        .map((entry) => entry.key)
        .toList();
  }
}
