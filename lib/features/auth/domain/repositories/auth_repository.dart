import 'package:money_track/core/error/result.dart';
import 'package:money_track/features/auth/domain/entities/user_entity.dart';

/// Repository interface for authentication operations
abstract class AuthRepository {
  /// Sign in with email and password
  Future<Result<UserEntity>> signInWithEmailAndPassword({
    required String email,
    required String password,
  });

  /// Sign up with email and password
  Future<Result<UserEntity>> signUpWithEmailAndPassword({
    required String email,
    required String password,
    String? displayName,
  });

  /// Sign out the current user
  Future<Result<void>> signOut();

  /// Get the current authenticated user
  Future<Result<UserEntity?>> getCurrentUser();

  /// Check if user is currently signed in
  Future<Result<bool>> isSignedIn();

  /// Send password reset email
  Future<Result<void>> sendPasswordResetEmail({
    required String email,
  });

  /// Send email verification
  Future<Result<void>> sendEmailVerification();

  /// Reload user data to get updated information
  Future<Result<UserEntity>> reloadUser();

  /// Delete the current user account
  Future<Result<void>> deleteAccount();

  /// Update user profile
  Future<Result<UserEntity>> updateProfile({
    String? displayName,
    String? photoUrl,
  });

  /// Stream of authentication state changes
  Stream<UserEntity?> get authStateChanges;
}
