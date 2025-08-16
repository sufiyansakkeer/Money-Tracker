import 'package:money_track/core/error/result.dart';
import 'package:money_track/core/use_cases/use_case.dart';
import 'package:money_track/features/auth/domain/entities/user_entity.dart';
import 'package:money_track/features/auth/domain/repositories/auth_repository.dart';

/// Parameters for sign in use case
class SignInParams {
  final String email;
  final String password;

  const SignInParams({
    required this.email,
    required this.password,
  });
}

/// Use case for signing in with email and password
class SignInUseCase implements UseCase<Result<UserEntity>, SignInParams> {
  final AuthRepository repository;

  SignInUseCase(this.repository);

  @override
  Future<Result<UserEntity>> call({SignInParams? params}) {
    if (params == null) {
      throw ArgumentError('SignInParams cannot be null');
    }
    return repository.signInWithEmailAndPassword(
      email: params.email,
      password: params.password,
    );
  }
}
