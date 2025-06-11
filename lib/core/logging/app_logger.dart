import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

/// Enhanced logging system for the application
class AppLogger {
  static final AppLogger _instance = AppLogger._internal();
  factory AppLogger() => _instance;
  AppLogger._internal();

  late final Logger _logger;

  /// Initialize the logger
  void initialize({bool enableFileLogging = false}) {
    _logger = Logger(
      filter: _AppLogFilter(),
      printer: _AppLogPrinter(),
      output: _AppLogOutput(enableFileLogging: enableFileLogging),
      level: kDebugMode ? Level.debug : Level.info,
    );
  }

  /// Log debug message
  void debug(String message,
      {String? tag, Object? error, StackTrace? stackTrace}) {
    _logger.d(message, error: error, stackTrace: stackTrace);
    _logToDeveloperConsole(message, tag: tag, level: 'DEBUG');
  }

  /// Log info message
  void info(String message,
      {String? tag, Object? error, StackTrace? stackTrace}) {
    _logger.i(message, error: error, stackTrace: stackTrace);
    _logToDeveloperConsole(message, tag: tag, level: 'INFO');
  }

  /// Log warning message
  void warning(String message,
      {String? tag, Object? error, StackTrace? stackTrace}) {
    _logger.w(message, error: error, stackTrace: stackTrace);
    _logToDeveloperConsole(message, tag: tag, level: 'WARNING');
  }

  /// Log error message
  void error(String message,
      {String? tag, Object? error, StackTrace? stackTrace}) {
    _logger.e(message, error: error, stackTrace: stackTrace);
    _logToDeveloperConsole(message, tag: tag, level: 'ERROR');
  }

  /// Log fatal error
  void fatal(String message,
      {String? tag, Object? error, StackTrace? stackTrace}) {
    _logger.f(message, error: error, stackTrace: stackTrace);
    _logToDeveloperConsole(message, tag: tag, level: 'FATAL');
  }

  /// Log BLoC events
  void blocEvent(String blocName, String event, {Map<String, dynamic>? data}) {
    final message = 'BLoC Event: $blocName -> $event';
    debug(message, tag: 'BLOC_EVENT');
    if (data != null) {
      debug('Event Data: $data', tag: 'BLOC_EVENT');
    }
  }

  /// Log BLoC state changes
  void blocState(String blocName, String state, {Map<String, dynamic>? data}) {
    final message = 'BLoC State: $blocName -> $state';
    debug(message, tag: 'BLOC_STATE');
    if (data != null) {
      debug('State Data: $data', tag: 'BLOC_STATE');
    }
  }

  /// Log API calls
  void apiCall(String method, String endpoint, {Map<String, dynamic>? params}) {
    final message = 'API Call: $method $endpoint';
    info(message, tag: 'API');
    if (params != null) {
      debug('API Params: $params', tag: 'API');
    }
  }

  /// Log API responses
  void apiResponse(String endpoint, int statusCode, {String? responseBody}) {
    final message = 'API Response: $endpoint -> $statusCode';
    info(message, tag: 'API');
    if (responseBody != null && kDebugMode) {
      debug('Response Body: $responseBody', tag: 'API');
    }
  }

  /// Log database operations
  void database(String operation, String table, {Map<String, dynamic>? data}) {
    final message = 'DB Operation: $operation on $table';
    debug(message, tag: 'DATABASE');
    if (data != null) {
      debug('DB Data: $data', tag: 'DATABASE');
    }
  }

  /// Log navigation events
  void navigation(String from, String to, {Map<String, dynamic>? arguments}) {
    final message = 'Navigation: $from -> $to';
    debug(message, tag: 'NAVIGATION');
    if (arguments != null) {
      debug('Navigation Args: $arguments', tag: 'NAVIGATION');
    }
  }

  /// Log performance metrics
  void performance(String operation, Duration duration,
      {Map<String, dynamic>? metrics}) {
    final message = 'Performance: $operation took ${duration.inMilliseconds}ms';
    info(message, tag: 'PERFORMANCE');
    if (metrics != null) {
      debug('Performance Metrics: $metrics', tag: 'PERFORMANCE');
    }
  }

  /// Log to developer console with tag
  void _logToDeveloperConsole(String message, {String? tag, String? level}) {
    final logTag = tag ?? 'MoneyTrack';
    final logMessage = level != null ? '[$level] $message' : message;
    developer.log(logMessage, name: logTag);
  }
}

/// Custom log filter
class _AppLogFilter extends LogFilter {
  @override
  bool shouldLog(LogEvent event) {
    // In release mode, only log warnings and errors
    if (kReleaseMode) {
      return event.level.index >= Level.warning.index;
    }
    // In debug mode, log everything
    return true;
  }
}

/// Custom log printer
class _AppLogPrinter extends LogPrinter {
  @override
  List<String> log(LogEvent event) {
    final color = PrettyPrinter.defaultLevelColors[event.level];
    final emoji = PrettyPrinter.defaultLevelEmojis[event.level];
    final timestamp = DateTime.now().toIso8601String();

    final message =
        '$emoji [$timestamp] ${event.level.name.toUpperCase()}: ${event.message}';

    if (event.error != null) {
      return [color!(message), 'Error: ${event.error}'];
    }

    return [color!(message)];
  }
}

/// Custom log output
class _AppLogOutput extends LogOutput {
  final bool enableFileLogging;

  _AppLogOutput({this.enableFileLogging = false});

  @override
  void output(OutputEvent event) {
    // Output to console
    for (final line in event.lines) {
      if (kDebugMode) {
        print(line);
      }
    }

    // TODO: Implement file logging if needed
    if (enableFileLogging) {
      _writeToFile(event.lines);
    }
  }

  void _writeToFile(List<String> lines) {
    // Implementation for file logging
    // This could write to a local file for debugging purposes
  }
}

/// Extension for easy logging
extension LoggerExtension on Object {
  void logDebug(String message, {Object? error, StackTrace? stackTrace}) {
    AppLogger().debug(message,
        tag: runtimeType.toString(), error: error, stackTrace: stackTrace);
  }

  void logInfo(String message, {Object? error, StackTrace? stackTrace}) {
    AppLogger().info(message,
        tag: runtimeType.toString(), error: error, stackTrace: stackTrace);
  }

  void logWarning(String message, {Object? error, StackTrace? stackTrace}) {
    AppLogger().warning(message,
        tag: runtimeType.toString(), error: error, stackTrace: stackTrace);
  }

  void logError(String message, {Object? error, StackTrace? stackTrace}) {
    AppLogger().error(message,
        tag: runtimeType.toString(), error: error, stackTrace: stackTrace);
  }
}
