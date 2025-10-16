import 'package:money_track/core/error/result.dart';
import 'package:money_track/core/use_cases/use_case.dart';
import 'package:money_track/features/groups/domain/repositories/group_repository.dart';

class DeleteGroup implements UseCase<Result<void>, String> {
  final GroupRepository repository;

  DeleteGroup(this.repository);

  @override
  Future<Result<void>> call({String? params}) {
    if (params == null) {
      throw ArgumentError('Group ID cannot be null');
    }
    return repository.deleteGroup(params);
  }
}
