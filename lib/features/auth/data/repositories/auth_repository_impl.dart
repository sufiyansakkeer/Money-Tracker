import 'package:money_track/core/error/failures.dart';
import 'package:money_track/core/error/result.dart';
import 'package:money_track/core/widgets/logger_service.dart'
    show LoggerService;
import 'package:money_track/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:money_track/features/auth/domain/entities/user_entity.dart';
import 'package:money_track/features/auth/domain/repositories/auth_repository.dart';

/// Implementation of AuthRepository
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final LoggerService logger = LoggerService();

  AuthRepositoryImpl({required this.remoteDataSource});

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
      return Success(userModel.toEntity());
    } catch (e) {
      logger.en(e.toString(),
          name: "AuthRepository signInWithEmailAndPassword");
      if (e is AuthFailure) {
        return Error(e);
      }
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
      return Success(userModel.toEntity());
    } catch (e) {
      logger.en(e.toString(),
          name: "AuthRepository signUpWithEmailAndPassword");
      if (e is AuthFailure) {
        return Error(e);
      }
      return Error(AuthFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<void>> signOut() async {
    try {
      await remoteDataSource.signOut();
      return const Success(null);
    } catch (e) {
      logger.en(e.toString(), name: "AuthRepository signOut");
      if (e is AuthFailure) {
        return Error(e);
      }
      return Error(AuthFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<UserEntity?>> getCurrentUser() async {
    try {
      final userModel = await remoteDataSource.getCurrentUser();
      return Success(userModel?.toEntity());
    } catch (e) {
      logger.en(e.toString(), name: "AuthRepository getCurrentUser");
      if (e is AuthFailure) {
        return Error(e);
      }
      return Error(AuthFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<bool>> isSignedIn() async {
    try {
      final isSignedIn = await remoteDataSource.isSignedIn();
      return Success(isSignedIn);
    } catch (e) {
      logger.en(e.toString(), name: "AuthRepository isSignedIn");
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
      logger.en(e.toString(), name: "AuthRepository sendPasswordResetEmail");
      if (e is AuthFailure) {
        return Error(e);
      }
      return Error(AuthFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<void>> sendEmailVerification() async {
    try {
      await remoteDataSource.sendEmailVerification();
      return const Success(null);
    } catch (e) {
      logger.en(e.toString(), name: "AuthRepository sendEmailVerification");
      if (e is AuthFailure) {
        return Error(e);
      }
      return Error(AuthFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<UserEntity>> reloadUser() async {
    try {
      final userModel = await remoteDataSource.reloadUser();
      return Success(userModel.toEntity());
    } catch (e) {
      logger.en(e.toString(), name: "AuthRepository reloadUser");
      if (e is AuthFailure) {
        return Error(e);
      }
      return Error(AuthFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<void>> deleteAccount() async {
    try {
      await remoteDataSource.deleteAccount();
      return const Success(null);
    } catch (e) {
      logger.en(e.toString(), name: "AuthRepository deleteAccount");
      if (e is AuthFailure) {
        return Error(e);
      }
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
      logger.en(e.toString(), name: "AuthRepository updateProfile");
      if (e is AuthFailure) {
        return Error(e);
      }
      return Error(AuthFailure(message: e.toString()));
    }
  }

  @override
  Stream<UserEntity?> get authStateChanges {
    return remoteDataSource.authStateChanges.map((userModel) {
      return userModel?.toEntity();
    });
  }
}
