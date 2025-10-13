import 'package:money_track/core/error/result.dart';
import 'package:money_track/core/use_cases/use_case.dart';
import 'package:money_track/features/auth/domain/repositories/auth_repository.dart';

/// Use case for sending password reset email
class SendPasswordResetUseCase implements UseCase<Result<void>, String> {
  final AuthRepository repository;

  SendPasswordResetUseCase(this.repository);

  @override
  Future<Result<void>> call({String? params}) {
    if (params == null) {
      throw ArgumentError('Email cannot be null');
    }
    return repository.sendPasswordResetEmail(email: params);
  }
}
