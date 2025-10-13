import 'package:money_track/core/error/result.dart';
import 'package:money_track/core/use_cases/use_case.dart';
import 'package:money_track/features/auth/domain/repositories/auth_repository.dart';

/// Use case for signing out the current user
class SignOutUseCase implements UseCase<Result<void>, NoParams> {
  final AuthRepository repository;

  SignOutUseCase(this.repository);

  @override
  Future<Result<void>> call({NoParams? params}) {
    return repository.signOut();
  }
}
