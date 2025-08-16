part of 'auth_bloc.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// Event to check authentication status
class CheckAuthStatusEvent extends AuthEvent {}

/// Event to sign in with email and password
class SignInEvent extends AuthEvent {
  final String email;
  final String password;

  const SignInEvent({
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [email, password];
}

/// Event to sign up with email and password
class SignUpEvent extends AuthEvent {
  final String email;
  final String password;
  final String? displayName;

  const SignUpEvent({
    required this.email,
    required this.password,
    this.displayName,
  });

  @override
  List<Object?> get props => [email, password, displayName];
}

/// Event to sign out
class SignOutEvent extends AuthEvent {}

/// Event to send password reset email
class SendPasswordResetEvent extends AuthEvent {
  final String email;

  const SendPasswordResetEvent({required this.email});

  @override
  List<Object?> get props => [email];
}

/// Event to send email verification
class SendEmailVerificationEvent extends AuthEvent {}

/// Event to reload user data
class ReloadUserEvent extends AuthEvent {}

/// Event to delete user account
class DeleteAccountEvent extends AuthEvent {}

/// Event to update user profile
class UpdateProfileEvent extends AuthEvent {
  final String? displayName;
  final String? photoUrl;

  const UpdateProfileEvent({
    this.displayName,
    this.photoUrl,
  });

  @override
  List<Object?> get props => [displayName, photoUrl];
}

/// Event triggered by auth state changes
class AuthStateChangedEvent extends AuthEvent {
  final UserEntity? user;

  const AuthStateChangedEvent({this.user});

  @override
  List<Object?> get props => [user];
}
