import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

/// A custom logger service that encapsulates the logger's configuration.
/// This makes it easy to manage logging throughout the app and switch
/// logging implementations if needed.
class LoggerService {
  late final Logger _logger;

  LoggerService() {
    _logger = Logger(
      // Set the log level based on the app's build mode.
      // In debug mode, all logs are shown. In release mode, only warnings and errors.
      level: kDebugMode ? Level.trace : Level.warning,
      printer: PrettyPrinter(
        methodCount: 1, // Number of method calls to be displayed
        errorMethodCount: 8, // Number of method calls if stacktrace is provided
        lineLength: 120, // Width of the log print
        colors: true, // Colorful log messages
        printEmojis: true, // Print an emoji for each log message
        dateTimeFormat: DateTimeFormat
            .onlyTimeAndSinceStart, // Should each log print contain a timestamp
      ),
    );
  }

  // Define methods for each log level to be used in the app.
  void t(dynamic message, {dynamic error, StackTrace? stackTrace}) =>
      _logger.t(message, error: error, stackTrace: stackTrace);
  void d(dynamic message, {dynamic error, StackTrace? stackTrace}) =>
      _logger.d(message, error: error, stackTrace: stackTrace);
  void i(dynamic message, {dynamic error, StackTrace? stackTrace}) =>
      _logger.i(message, error: error, stackTrace: stackTrace);
  void w(dynamic message, {dynamic error, StackTrace? stackTrace}) =>
      _logger.w(message, error: error, stackTrace: stackTrace);
  void e(dynamic message, {dynamic error, StackTrace? stackTrace}) =>
      _logger.e(message, error: error, stackTrace: stackTrace);
  void en(dynamic message, {dynamic name, StackTrace? stackTrace}) =>
      _logger.e(message, error: name, stackTrace: stackTrace);
  void wtf(dynamic message, {dynamic error, StackTrace? stackTrace}) =>
      _logger.f(message, error: error, stackTrace: stackTrace);
}
