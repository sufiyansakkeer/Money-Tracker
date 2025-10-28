import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

/// A centralized logger service for the app.
class LoggerService {
  // 👇 The single shared instance (singleton)
  static final LoggerService instance = LoggerService._internal();

  late final Logger _logger;

  LoggerService._internal() {
    _logger = Logger(
      // Set log level depending on build mode
      level: kDebugMode ? Level.trace : Level.warning,
      printer: PrettyPrinter(
        methodCount: 1, // Number of method calls to show
        errorMethodCount: 8, // Lines to show for errors
        lineLength: 120, // Width of the log output
        colors: true,
        printEmojis: true,
        dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
      ),
    );
  }

  /// TRACE logs (for very detailed dev logs)
  void t(dynamic message, {dynamic error, StackTrace? stackTrace}) =>
      _logger.t(message, error: error, stackTrace: stackTrace);

  /// DEBUG logs
  void d(dynamic message, {dynamic error, StackTrace? stackTrace}) =>
      _logger.d(message, error: error, stackTrace: stackTrace);

  /// INFO logs
  void i(dynamic message, {dynamic error, StackTrace? stackTrace}) =>
      _logger.i(message, error: error, stackTrace: stackTrace);

  /// WARNING logs
  void w(dynamic message, {dynamic error, StackTrace? stackTrace}) =>
      _logger.w(message, error: error, stackTrace: stackTrace);

  /// ERROR logs
  void e(dynamic message, {dynamic error, StackTrace? stackTrace}) =>
      _logger.e(message, error: error, stackTrace: stackTrace);

  /// NAMED ERROR (custom extra param)
  void en(dynamic message, {dynamic name, StackTrace? stackTrace}) =>
      _logger.e(message, error: name, stackTrace: stackTrace);

  /// FATAL logs
  void wtf(dynamic message, {dynamic error, StackTrace? stackTrace}) =>
      _logger.f(message, error: error, stackTrace: stackTrace);
}
