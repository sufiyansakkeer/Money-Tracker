import 'package:money_track/core/error/result.dart';
import 'package:money_track/core/use_cases/use_case.dart';
import 'package:money_track/features/groups/domain/entities/group_entity.dart';
import 'package:money_track/features/groups/domain/repositories/group_repository.dart';

class GetGroups implements UseCase<Result<List<GroupEntity>>, NoParams> {
  final GroupRepository repository;

  GetGroups(this.repository);

  @override
  Future<Result<List<GroupEntity>>> call({NoParams? params}) {
    return repository.getGroups();
  }
}
