part of 'auth_bloc.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class AuthInitial extends AuthState {}

/// Loading state
class AuthLoading extends AuthState {}

/// Authenticated state
class AuthAuthenticated extends AuthState {
  final UserEntity user;

  const AuthAuthenticated({required this.user});

  @override
  List<Object?> get props => [user];
}

/// Unauthenticated state
class AuthUnauthenticated extends AuthState {}

/// Error state
class AuthError extends AuthState {
  final String message;

  const AuthError({required this.message});

  @override
  List<Object?> get props => [message];
}

/// Success state for operations that don't return user data
class AuthOperationSuccess extends AuthState {
  final String message;

  const AuthOperationSuccess({required this.message});

  @override
  List<Object?> get props => [message];
}

/// State for password reset email sent
class PasswordResetEmailSent extends AuthState {
  final String email;

  const PasswordResetEmailSent({required this.email});

  @override
  List<Object?> get props => [email];
}

/// State for email verification sent
class EmailVerificationSent extends AuthState {}

/// State for account deleted
class AccountDeleted extends AuthState {}
