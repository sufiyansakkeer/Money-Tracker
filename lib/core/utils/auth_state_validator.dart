import 'dart:developer';
import 'package:firebase_auth/firebase_auth.dart';

/// Authentication state validator for debugging auth issues
class AuthStateValidator {
  final FirebaseAuth _firebaseAuth;

  AuthStateValidator({
    required FirebaseAuth firebaseAuth,
  }) : _firebaseAuth = firebaseAuth;

  /// Comprehensive authentication state check
  Future<AuthValidationResult> validateAuthState() async {
    final result = AuthValidationResult();

    try {
      // Check current user
      final user = _firebaseAuth.currentUser;
      result.hasCurrentUser = user != null;
      result.userId = user?.uid;

      if (user == null) {
        result.errors.add('No current user found');
        result.isValid = false;
        return result;
      }

      // Check if user is authenticated
      result.isAuthenticated = user.uid.isNotEmpty;

      // Check token validity
      try {
        final idTokenResult = await user.getIdTokenResult();
        result.tokenValid = true;
        result.tokenExpirationTime = idTokenResult.expirationTime;
        result.tokenIssuedAt = idTokenResult.issuedAtTime;

        // Check if token is expired or about to expire (within 5 minutes)
        final now = DateTime.now();
        final expirationBuffer = Duration(minutes: 5);
        result.tokenNearExpiry = idTokenResult.expirationTime != null &&
            idTokenResult.expirationTime!.isBefore(now.add(expirationBuffer));

        if (result.tokenNearExpiry) {
          result.warnings.add('Authentication token expires soon');
        }
      } catch (e) {
        result.tokenValid = false;
        result.errors.add('Failed to get ID token: $e');
        log('Token validation failed: $e', name: 'AuthStateValidator');
      }

      // Skip Firestore permissions test since sync is removed
      result.firestorePermissionsValid = true;

      // Check user email verification status
      result.emailVerified = user.emailVerified;
      if (!user.emailVerified) {
        result.warnings.add('User email is not verified');
      }

      // Check if user is disabled
      try {
        await user.reload();
        final refreshedUser = _firebaseAuth.currentUser;
        result.userActive = refreshedUser != null;
      } catch (e) {
        result.userActive = false;
        result.errors.add('User account may be disabled: $e');
      }

      // Overall validation
      result.isValid = result.hasCurrentUser &&
          result.isAuthenticated &&
          result.tokenValid &&
          result.firestorePermissionsValid &&
          result.userActive;
    } catch (e) {
      result.isValid = false;
      result.errors.add('Authentication validation failed: $e');
      log('Auth state validation error: $e', name: 'AuthStateValidator');
    }

    return result;
  }

  /// Force token refresh
  Future<bool> refreshAuthToken() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        log('Cannot refresh token: no current user',
            name: 'AuthStateValidator');
        return false;
      }

      await user.getIdToken(true); // Force refresh
      log('Authentication token refreshed successfully',
          name: 'AuthStateValidator');
      return true;
    } catch (e) {
      log('Failed to refresh authentication token: $e',
          name: 'AuthStateValidator');
      return false;
    }
  }

  /// Get detailed authentication info for logging
  Future<Map<String, dynamic>> getAuthDebugInfo() async {
    final user = _firebaseAuth.currentUser;
    if (user == null) {
      return {'error': 'No current user'};
    }

    try {
      final idTokenResult = await user.getIdTokenResult();
      return {
        'uid': user.uid,
        'email': user.email,
        'emailVerified': user.emailVerified,
        'isAnonymous': user.isAnonymous,
        'tokenIssuedAt': idTokenResult.issuedAtTime?.toIso8601String(),
        'tokenExpirationTime': idTokenResult.expirationTime?.toIso8601String(),
        'authTime': idTokenResult.authTime?.toIso8601String(),
        'signInProvider': idTokenResult.signInProvider,
        'claims': idTokenResult.claims,
      };
    } catch (e) {
      return {
        'uid': user.uid,
        'email': user.email,
        'error': 'Failed to get token info: $e'
      };
    }
  }
}

/// Result of authentication state validation
class AuthValidationResult {
  bool isValid = false;
  bool hasCurrentUser = false;
  bool isAuthenticated = false;
  bool tokenValid = false;
  bool tokenNearExpiry = false;
  bool firestorePermissionsValid = false;
  bool emailVerified = false;
  bool userActive = false;

  String? userId;
  DateTime? tokenExpirationTime;
  DateTime? tokenIssuedAt;

  List<String> errors = [];
  List<String> warnings = [];

  /// Get a summary of the validation result
  String getSummary() {
    final buffer = StringBuffer();
    buffer.writeln('Authentication State Validation:');
    buffer.writeln('  Valid: $isValid');
    buffer.writeln('  User ID: ${userId ?? 'null'}');
    buffer.writeln('  Authenticated: $isAuthenticated');
    buffer.writeln('  Token Valid: $tokenValid');
    buffer.writeln('  Token Near Expiry: $tokenNearExpiry');
    buffer.writeln('  Firestore Permissions: $firestorePermissionsValid');
    buffer.writeln('  Email Verified: $emailVerified');
    buffer.writeln('  User Active: $userActive');

    if (errors.isNotEmpty) {
      buffer.writeln('  Errors:');
      for (final error in errors) {
        buffer.writeln('    - $error');
      }
    }

    if (warnings.isNotEmpty) {
      buffer.writeln('  Warnings:');
      for (final warning in warnings) {
        buffer.writeln('    - $warning');
      }
    }

    return buffer.toString();
  }
}
