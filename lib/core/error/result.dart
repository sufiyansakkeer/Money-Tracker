import 'package:equatable/equatable.dart';
import 'package:money_track/core/error/failures.dart';

/// A generic class that holds a value with success or failure
abstract class Result<T> extends Equatable {
  const Result();

  @override
  List<Object?> get props => [];

  /// Fold method to handle both success and failure cases
  R fold<R>(
    R Function(T) success,
    R Function(Failure) error,
  );
}

/// Success case with data
class Success<T> extends Result<T> {
  final T data;

  const Success(this.data);

  @override
  List<Object?> get props => [data];

  @override
  R fold<R>(
    R Function(T) success,
    R Function(Failure) error,
  ) {
    return success(data);
  }
}

/// Failure case with error
class Error<T> extends Result<T> {
  final Failure failure;

  const Error(this.failure);

  @override
  List<Object?> get props => [failure];

  @override
  R fold<R>(
    R Function(T) success,
    R Function(Failure) error,
  ) {
    return error(failure);
  }
}
