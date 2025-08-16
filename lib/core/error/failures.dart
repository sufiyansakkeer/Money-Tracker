import 'package:equatable/equatable.dart';

/// Base class for all failures in the application
abstract class Failure extends Equatable {
  final String message;

  const Failure({required this.message});

  @override
  List<Object> get props => [message];
}

/// Failure for database operations
class DatabaseFailure extends Failure {
  const DatabaseFailure({required super.message});
}

/// Failure for general server errors
class ServerFailure extends Failure {
  const ServerFailure({required super.message});
}

/// Failure for cache operations
class CacheFailure extends Failure {
  const CacheFailure({required super.message});
}

/// Failure for validation errors
class ValidationFailure extends Failure {
  const ValidationFailure({required super.message});
}

/// Failure for authentication errors
class AuthFailure extends Failure {
  const AuthFailure({required super.message});
}

/// Failure for network-related errors
class NetworkFailure extends Failure {
  const NetworkFailure({required super.message});
}
