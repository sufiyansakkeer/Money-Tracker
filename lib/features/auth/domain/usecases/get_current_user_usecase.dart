import 'package:money_track/core/error/result.dart';
import 'package:money_track/core/use_cases/use_case.dart';
import 'package:money_track/features/auth/domain/entities/user_entity.dart';
import 'package:money_track/features/auth/domain/repositories/auth_repository.dart';

/// Use case for getting the current authenticated user
class GetCurrentUserUseCase implements UseCase<Result<UserEntity?>, NoParams> {
  final AuthRepository repository;

  GetCurrentUserUseCase(this.repository);

  @override
  Future<Result<UserEntity?>> call({NoParams? params}) {
    return repository.getCurrentUser();
  }
}
