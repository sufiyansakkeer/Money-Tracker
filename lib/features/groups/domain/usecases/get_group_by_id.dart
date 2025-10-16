import 'package:money_track/core/error/result.dart';
import 'package:money_track/core/use_cases/use_case.dart';
import 'package:money_track/features/groups/domain/entities/group_entity.dart';
import 'package:money_track/features/groups/domain/repositories/group_repository.dart';

class GetGroupById implements UseCase<Result<GroupEntity?>, String> {
  final GroupRepository repository;

  GetGroupById(this.repository);

  @override
  Future<Result<GroupEntity?>> call({String? params}) {
    if (params == null) {
      throw ArgumentError('Group ID cannot be null');
    }
    return repository.getGroupById(params);
  }
}