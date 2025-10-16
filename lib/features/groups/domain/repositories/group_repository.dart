import 'package:money_track/core/error/result.dart';
import 'package:money_track/features/groups/domain/entities/group_entity.dart';

abstract class GroupRepository {
  Future<Result<void>> createGroup(GroupEntity group);
  Future<Result<void>> updateGroup(GroupEntity group);
  Future<Result<void>> deleteGroup(String groupId);
  Future<Result<List<GroupEntity>>> getGroups();
  Future<Result<GroupEntity?>> getGroupById(String groupId);
}