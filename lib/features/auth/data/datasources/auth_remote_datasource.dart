import 'package:firebase_auth/firebase_auth.dart';
import 'package:money_track/core/error/failures.dart';
import 'package:money_track/core/widgets/logger_service.dart';
import 'package:money_track/features/auth/data/models/user_model.dart';

/// Abstract class for authentication remote data source
abstract class AuthRemoteDataSource {
  /// Sign in with email and password
  Future<UserModel> signInWithEmailAndPassword({
    required String email,
    required String password,
  });

  /// Sign up with email and password
  Future<UserModel> signUpWithEmailAndPassword({
    required String email,
    required String password,
    String? displayName,
  });

  /// Sign out the current user
  Future<void> signOut();

  /// Get the current authenticated user
  Future<UserModel?> getCurrentUser();

  /// Check if user is currently signed in
  Future<bool> isSignedIn();

  /// Send password reset email
  Future<void> sendPasswordResetEmail({
    required String email,
  });

  /// Send email verification
  Future<void> sendEmailVerification();

  /// Reload user data to get updated information
  Future<UserModel> reloadUser();

  /// Delete the current user account
  Future<void> deleteAccount();

  /// Update user profile
  Future<UserModel> updateProfile({
    String? displayName,
    String? photoUrl,
  });

  /// Stream of authentication state changes
  Stream<UserModel?> get authStateChanges;
}

/// Implementation of authentication remote data source using Firebase
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final FirebaseAuth firebaseAuth;
  final LoggerService logger = LoggerService();

  AuthRemoteDataSourceImpl({required this.firebaseAuth});

  @override
  Future<UserModel> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user == null) {
        logger.e('Sign in failed: No user returned',
            error: "Sign in with email and password exception");
        throw const AuthFailure(message: 'Sign in failed: No user returned');
      }
      logger.t('User signed in: ${credential.user?.uid ?? 'null'}',
          error: "Sign in successful");

      return UserModel.fromFirebaseUser(credential.user!);
    } on FirebaseAuthException catch (e) {
      logger.e(e.toString(),
          error: "Sign in with email and password exception");
      throw AuthFailure(message: _getAuthErrorMessage(e.code));
    } catch (e) {
      logger.e(e.toString(),
          error: "Sign in with email and password exception");
      throw AuthFailure(message: "Sign in failed: ${e.toString()}");
    }
  }

  @override
  Future<UserModel> signUpWithEmailAndPassword({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      final credential = await firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user == null) {
        logger.e('Sign up failed: No user returned',
            error: "Sign up with email and password exception");
        throw const AuthFailure(message: 'Sign up failed: No user returned');
      }

      // Update display name if provided
      if (displayName != null && displayName.isNotEmpty) {
        await credential.user!.updateDisplayName(displayName);
        await credential.user!.reload();
      }
      logger.t('User signed up: ${credential.user?.uid ?? 'null'}',
          error: "Sign up successful");

      return UserModel.fromFirebaseUser(credential.user!);
    } on FirebaseAuthException catch (e) {
      logger.e(e.toString(),
          error: "Sign up with email and password exception");
      throw AuthFailure(message: _getAuthErrorMessage(e.code));
    } catch (e) {
      logger.e(e.toString(),
          error: "Sign up with email and password exception");
      throw AuthFailure(message: "Sign up failed: ${e.toString()}");
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await firebaseAuth.signOut();
      logger.t('User signed out', error: "Sign out successful");
    } catch (e) {
      logger.e(e.toString(), error: "Sign out exception");
      throw AuthFailure(message: "Sign out failed: ${e.toString()}");
    }
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    try {
      final user = firebaseAuth.currentUser;
      logger.t('Current user: ${user?.uid ?? 'null'}',
          error: "Get current user successful");

      if (user == null) return null;

      // Reload to get the latest user data
      await user.reload();
      final refreshedUser = firebaseAuth.currentUser;
      logger.t('Refreshed user: ${refreshedUser?.uid ?? 'null'}',
          error: "Get current user successful");

      return refreshedUser != null
          ? UserModel.fromFirebaseUser(refreshedUser)
          : null;
    } catch (e) {
      logger.e(e.toString(), error: "Get current user exception");
      throw AuthFailure(message: "Failed to get current user: ${e.toString()}");
    }
  }

  @override
  Future<bool> isSignedIn() async {
    try {
      logger.t('Checking if user is signed in',
          error: "Is signed in successful");

      return firebaseAuth.currentUser != null;
    } catch (e) {
      logger.en(e.toString(), name: "Is signed in exception");

      return false;
    }
  }

  @override
  Future<void> sendPasswordResetEmail({required String email}) async {
    try {
      await firebaseAuth.sendPasswordResetEmail(email: email);
      logger.t('Password reset email sent',
          error: "Send password reset email successful");
    } on FirebaseAuthException catch (e) {
      logger.e(e.toString(), error: "Send password reset email exception");
      throw AuthFailure(message: _getAuthErrorMessage(e.code));
    } catch (e) {
      logger.e(e.toString(), error: "Send password reset email exception");
      throw AuthFailure(
          message: "Failed to send password reset email: ${e.toString()}");
    }
  }

  @override
  Future<void> sendEmailVerification() async {
    try {
      final user = firebaseAuth.currentUser;
      if (user == null) {
        throw const AuthFailure(message: 'No user is currently signed in');
      }
      await user.sendEmailVerification();
    } on FirebaseAuthException catch (e) {
      logger.en(e.toString(), name: "Send email verification exception");
      throw AuthFailure(message: _getAuthErrorMessage(e.code));
    } catch (e) {
      logger.en(e.toString(), name: "Send email verification exception");
      throw AuthFailure(
          message: "Failed to send email verification: ${e.toString()}");
    }
  }

  @override
  Future<UserModel> reloadUser() async {
    try {
      final user = firebaseAuth.currentUser;
      if (user == null) {
        logger.e('No user is currently signed in',
            error: "Reload user exception");
        throw const AuthFailure(message: 'No user is currently signed in');
      }

      await user.reload();
      final refreshedUser = firebaseAuth.currentUser;

      if (refreshedUser == null) {
        logger.e('Failed to reload user data', error: "Reload user exception");
        throw const AuthFailure(message: 'Failed to reload user data');
      }

      return UserModel.fromFirebaseUser(refreshedUser);
    } catch (e) {
      logger.e(e.toString(), error: "Reload user exception");
      throw AuthFailure(message: "Failed to reload user: ${e.toString()}");
    }
  }

  @override
  Future<void> deleteAccount() async {
    try {
      final user = firebaseAuth.currentUser;
      if (user == null) {
        throw const AuthFailure(message: 'No user is currently signed in');
      }
      await user.delete();
    } on FirebaseAuthException catch (e) {
      logger.e(e.toString(), error: "Delete account exception");
      throw AuthFailure(message: _getAuthErrorMessage(e.code));
    } catch (e) {
      logger.e(e.toString(), error: "Delete account exception");
      throw AuthFailure(message: "Failed to delete account: ${e.toString()}");
    }
  }

  @override
  Future<UserModel> updateProfile({
    String? displayName,
    String? photoUrl,
  }) async {
    try {
      final user = firebaseAuth.currentUser;
      if (user == null) {
        throw const AuthFailure(message: 'No user is currently signed in');
      }

      if (displayName != null) {
        await user.updateDisplayName(displayName);
      }

      if (photoUrl != null) {
        await user.updatePhotoURL(photoUrl);
      }

      await user.reload();
      final refreshedUser = firebaseAuth.currentUser;

      if (refreshedUser == null) {
        throw const AuthFailure(message: 'Failed to update user profile');
      }

      return UserModel.fromFirebaseUser(refreshedUser);
    } on FirebaseAuthException catch (e) {
      logger.e(e.toString(), error: "Update profile exception");
      throw AuthFailure(message: _getAuthErrorMessage(e.code));
    } catch (e) {
      logger.e(e.toString(), error: "Update profile exception");
      throw AuthFailure(message: "Failed to update profile: ${e.toString()}");
    }
  }

  @override
  Stream<UserModel?> get authStateChanges {
    return firebaseAuth.authStateChanges().map((user) {
      return user != null ? UserModel.fromFirebaseUser(user) : null;
    });
  }

  /// Helper method to get user-friendly error messages
  String _getAuthErrorMessage(String errorCode) {
    switch (errorCode) {
      case 'user-not-found':
        return 'No user found with this email address.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'email-already-in-use':
        return 'An account already exists with this email address.';
      case 'weak-password':
        return 'Password is too weak. Please choose a stronger password.';
      case 'invalid-email':
        return 'Invalid email address format.';
      case 'user-disabled':
        return 'This user account has been disabled.';
      case 'too-many-requests':
        return 'Too many failed attempts. Please try again later.';
      case 'operation-not-allowed':
        return 'This operation is not allowed.';
      case 'requires-recent-login':
        return 'This operation requires recent authentication. Please sign in again.';
      default:
        return 'Authentication failed. Please try again.';
    }
  }
}
