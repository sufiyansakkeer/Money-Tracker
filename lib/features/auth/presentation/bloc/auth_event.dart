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
  final String? username;
  final String? phone;

  const SignUpEvent({
    required this.email,
    required this.password,
    this.displayName,
    this.username,
    this.phone,
  });

  @override
  List<Object?> get props => [email, password, displayName, username, phone];
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
  final String? username;
  final String? photoUrl;

  const UpdateProfileEvent({
    this.displayName,
    this.username,
    this.photoUrl,
  });

  @override
  List<Object?> get props => [displayName, username, photoUrl];
}

/// Event to update username specifically
class UpdateUsernameEvent extends AuthEvent {
  final String username;

  const UpdateUsernameEvent({required this.username});

  @override
  List<Object?> get props => [username];
}

/// Event triggered by auth state changes
class AuthStateChangedEvent extends AuthEvent {
  final UserEntity? user;

  const AuthStateChangedEvent({this.user});

  @override
  List<Object?> get props => [user];
}
