import 'package:money_track/core/error/result.dart';
import 'package:money_track/core/use_cases/use_case.dart';
import 'package:money_track/features/auth/domain/entities/user_entity.dart';
import 'package:money_track/features/auth/domain/repositories/auth_repository.dart';

/// Parameters for sign up use case
class SignUpParams {
  final String email;
  final String password;
  final String? displayName;

  const SignUpParams({
    required this.email,
    required this.password,
    this.displayName,
  });
}

/// Use case for signing up with email and password
class SignUpUseCase implements UseCase<Result<UserEntity>, SignUpParams> {
  final AuthRepository repository;

  SignUpUseCase(this.repository);

  @override
  Future<Result<UserEntity>> call({SignUpParams? params}) {
    if (params == null) {
      throw ArgumentError('SignUpParams cannot be null');
    }
    return repository.signUpWithEmailAndPassword(
      email: params.email,
      password: params.password,
      displayName: params.displayName,
    );
  }
}
