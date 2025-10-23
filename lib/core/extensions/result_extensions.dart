import 'package:money_track/core/error/failures.dart';
import 'package:money_track/core/error/result.dart';

/// Extension methods for Result class to provide convenience properties and methods
extension ResultExtensions<T> on Result<T> {
  /// Check if the result is an error
  bool get isError => this is Error<T>;

  /// Check if the result is a success
  bool get isSuccess => this is Success<T>;

  /// Get the data if success, null if error
  T? get data => isSuccess ? (this as Success<T>).data : null;

  /// Get the failure if error, null if success
  Failure? get failure => isError ? (this as Error<T>).failure : null;

  /// Get the error (alias for failure)
  Failure? get error => failure;
}

/// Static factory methods for Result class
class ResultFactory {
  /// Create a success result
  static Result<T> success<T>(T data) => Success<T>(data);

  /// Create an error result
  static Result<T> error<T>(Failure failure) => Error<T>(failure);
}
