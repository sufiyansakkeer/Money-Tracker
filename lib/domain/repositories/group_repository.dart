import 'package:money_track/domain/entities/group.dart';

abstract class GroupRepository {
  Future<void> createGroup(GroupEntity group);
  Future<void> updateGroup(GroupEntity group);
  Future<void> deleteGroup(String groupId);
  Future<List<GroupEntity>> getGroups();
}
