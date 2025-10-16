import 'package:money_track/core/error/result.dart';
import 'package:money_track/core/use_cases/use_case.dart';
import 'package:money_track/features/groups/domain/entities/group_entity.dart';
import 'package:money_track/features/groups/domain/repositories/group_repository.dart';

class CreateGroup implements UseCase<Result<void>, GroupEntity> {
  final GroupRepository repository;

  CreateGroup(this.repository);

  @override
  Future<Result<void>> call({GroupEntity? params}) {
    if (params == null) {
      throw ArgumentError('GroupEntity cannot be null');
    }
    return repository.createGroup(params);
  }
}
