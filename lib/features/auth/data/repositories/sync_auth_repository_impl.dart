import 'dart:developer';
import 'package:money_track/core/error/failures.dart';
import 'package:money_track/core/error/result.dart';
import 'package:money_track/core/services/connectivity_service.dart';
import 'package:money_track/core/services/sync_service.dart';
import 'package:money_track/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:money_track/features/auth/domain/entities/user_entity.dart';
import 'package:money_track/features/auth/domain/repositories/auth_repository.dart';

/// Enhanced authentication repository with sync integration
class SyncAuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final SyncService syncService;
  final ConnectivityService connectivityService;

  SyncAuthRepositoryImpl({
    required this.remoteDataSource,
    required this.syncService,
    required this.connectivityService,
  });

  @override
  Future<Result<UserEntity>> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final userModel = await remoteDataSource.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final userEntity = userModel.toEntity();

      // Initialize sync service for the user
      await _initializeSyncForUser(userEntity.uid);

      return Success(userEntity);
    } catch (e) {
      log(e.toString(), name: "SyncAuthRepository signInWithEmailAndPassword");
      return Error(AuthFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<UserEntity>> signUpWithEmailAndPassword({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      final userModel = await remoteDataSource.signUpWithEmailAndPassword(
        email: email,
        password: password,
        displayName: displayName,
      );

      final userEntity = userModel.toEntity();

      // Initialize sync service for the new user
      await _initializeSyncForUser(userEntity.uid);

      return Success(userEntity);
    } catch (e) {
      log(e.toString(), name: "SyncAuthRepository signUpWithEmailAndPassword");
      return Error(AuthFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<void>> signOut() async {
    try {
      // Clear all local data before signing out
      await syncService.clearLocalData();

      // Sign out from Firebase
      await remoteDataSource.signOut();

      return const Success(null);
    } catch (e) {
      log(e.toString(), name: "SyncAuthRepository signOut");
      return Error(AuthFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<UserEntity?>> getCurrentUser() async {
    try {
      final userModel = await remoteDataSource.getCurrentUser();

      if (userModel != null) {
        final userEntity = userModel.toEntity();

        // Ensure sync service is initialized for the current user
        await _initializeSyncForUser(userEntity.uid);

        return Success(userEntity);
      }

      return const Success(null);
    } catch (e) {
      log(e.toString(), name: "SyncAuthRepository getCurrentUser");
      return Error(AuthFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<bool>> isSignedIn() async {
    try {
      final isSignedIn = await remoteDataSource.isSignedIn();
      return Success(isSignedIn);
    } catch (e) {
      log(e.toString(), name: "SyncAuthRepository isSignedIn");
      return const Success(false);
    }
  }

  @override
  Future<Result<void>> sendPasswordResetEmail({
    required String email,
  }) async {
    try {
      await remoteDataSource.sendPasswordResetEmail(email: email);
      return const Success(null);
    } catch (e) {
      log(e.toString(), name: "SyncAuthRepository sendPasswordResetEmail");
      return Error(AuthFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<void>> sendEmailVerification() async {
    try {
      await remoteDataSource.sendEmailVerification();
      return const Success(null);
    } catch (e) {
      log(e.toString(), name: "SyncAuthRepository sendEmailVerification");
      return Error(AuthFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<UserEntity>> reloadUser() async {
    try {
      final userModel = await remoteDataSource.reloadUser();
      return Success(userModel.toEntity());
    } catch (e) {
      log(e.toString(), name: "SyncAuthRepository reloadUser");
      return Error(AuthFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<void>> deleteAccount() async {
    try {
      // Clear all local data before deleting account
      await syncService.clearLocalData();

      // Delete account from Firebase
      await remoteDataSource.deleteAccount();

      return const Success(null);
    } catch (e) {
      log(e.toString(), name: "SyncAuthRepository deleteAccount");
      return Error(AuthFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<UserEntity>> updateProfile({
    String? displayName,
    String? photoUrl,
  }) async {
    try {
      final userModel = await remoteDataSource.updateProfile(
        displayName: displayName,
        photoUrl: photoUrl,
      );
      return Success(userModel.toEntity());
    } catch (e) {
      log(e.toString(), name: "SyncAuthRepository updateProfile");
      return Error(AuthFailure(message: e.toString()));
    }
  }

  @override
  Stream<UserEntity?> get authStateChanges {
    return remoteDataSource.authStateChanges.map((userModel) {
      if (userModel != null) {
        final userEntity = userModel.toEntity();
        // Initialize sync service when auth state changes to authenticated
        _initializeSyncForUser(userEntity.uid);
        return userEntity;
      } else {
        // Clear local data when auth state changes to unauthenticated
        syncService.clearLocalData();
        return null;
      }
    });
  }

  /// Initialize sync service for a user
  Future<void> _initializeSyncForUser(String userId) async {
    try {
      log('Initializing sync for user: $userId', name: 'SyncAuthRepository');

      // Initialize connectivity service if not already done
      await connectivityService.initialize();

      // Initialize sync service for the user
      await syncService.initializeForUser(userId);

      log('Sync initialized successfully for user: $userId',
          name: 'SyncAuthRepository');
    } catch (e) {
      log('Failed to initialize sync for user $userId: $e',
          name: 'SyncAuthRepository');
      // Don't throw error here as authentication succeeded
    }
  }

  /// Get sync status
  Future<Map<String, dynamic>> getSyncStatus() async {
    return await syncService.getSyncStats();
  }

  /// Force sync data
  Future<Result<void>> forceSync() async {
    try {
      final result = await syncService.forceSyncNow();
      if (result.success) {
        return const Success(null);
      } else {
        return Error(NetworkFailure(message: result.error ?? 'Sync failed'));
      }
    } catch (e) {
      log('Error forcing sync: $e', name: 'SyncAuthRepository');
      return Error(NetworkFailure(message: e.toString()));
    }
  }
}
