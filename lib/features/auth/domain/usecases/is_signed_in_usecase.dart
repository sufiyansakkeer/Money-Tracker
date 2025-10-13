import 'package:money_track/core/error/result.dart';
import 'package:money_track/core/use_cases/use_case.dart';
import 'package:money_track/features/auth/domain/repositories/auth_repository.dart';

/// Use case for checking if user is currently signed in
class IsSignedInUseCase implements UseCase<Result<bool>, NoParams> {
  final AuthRepository repository;

  IsSignedInUseCase(this.repository);

  @override
  Future<Result<bool>> call({NoParams? params}) {
    return repository.isSignedIn();
  }
}
