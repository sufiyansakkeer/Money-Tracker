import 'package:hive_ce/hive.dart';
import 'package:money_track/core/error/failures.dart';
import 'package:money_track/features/groups/data/models/group_model.dart';

abstract class GroupLocalDataSource {
  Future<List<GroupModel>> getGroups();
  Future<GroupModel?> getGroupById(String groupId);
  Future<void> createGroup(GroupModel group);
  Future<void> updateGroup(GroupModel group);
  Future<void> deleteGroup(String groupId);
}

class GroupLocalDataSourceImpl implements GroupLocalDataSource {
  final Box<GroupModel> groupBox;

  GroupLocalDataSourceImpl(this.groupBox);

  @override
  Future<List<GroupModel>> getGroups() async {
    try {
      return groupBox.values.toList();
    } catch (e) {
      throw DatabaseFailure(message: "Failed to get groups: ${e.toString()}");
    }
  }

  @override
  Future<GroupModel?> getGroupById(String groupId) async {
    try {
      return groupBox.get(groupId);
    } catch (e) {
      throw DatabaseFailure(message: "Failed to get group: ${e.toString()}");
    }
  }

  @override
  Future<void> createGroup(GroupModel group) async {
    try {
      await groupBox.put(group.id, group);
    } catch (e) {
      throw DatabaseFailure(message: "Failed to create group: ${e.toString()}");
    }
  }

  @override
  Future<void> updateGroup(GroupModel group) async {
    try {
      await groupBox.put(group.id, group);
    } catch (e) {
      throw DatabaseFailure(message: "Failed to update group: ${e.toString()}");
    }
  }

  @override
  Future<void> deleteGroup(String groupId) async {
    try {
      await groupBox.delete(groupId);
    } catch (e) {
      throw DatabaseFailure(message: "Failed to delete group: ${e.toString()}");
    }
  }
}
