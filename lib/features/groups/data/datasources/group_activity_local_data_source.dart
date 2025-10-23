import 'package:hive_ce/hive.dart';
import 'package:money_track/core/error/failures.dart';
import 'package:money_track/features/groups/data/models/group_activity_model.dart';

abstract class GroupActivityLocalDataSource {
  Future<List<GroupActivityModel>> getGroupActivities(String groupId);
  Future<List<GroupActivityModel>> getAllActivities();
  Future<GroupActivityModel?> getActivityById(String activityId);
  Future<void> addActivity(GroupActivityModel activity);
  Future<void> deleteActivity(String activityId);
  Future<List<GroupActivityModel>> getActivitiesByType(
    String groupId,
    GroupActivityTypeModel type,
  );
  Future<List<GroupActivityModel>> getActivitiesByDateRange(
    String groupId,
    DateTime startDate,
    DateTime endDate,
  );
  Future<List<GroupActivityModel>> getActivitiesByMember(
    String groupId,
    String memberId,
  );
  Future<void> clearOldActivities(DateTime cutoffDate);
}

class GroupActivityLocalDataSourceImpl implements GroupActivityLocalDataSource {
  final Box<GroupActivityModel> activityBox;

  GroupActivityLocalDataSourceImpl(this.activityBox);

  @override
  Future<List<GroupActivityModel>> getGroupActivities(String groupId) async {
    try {
      final activities = activityBox.values
          .where((activity) => activity.groupId == groupId)
          .toList();
      // Sort by timestamp (newest first)
      activities.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return activities;
    } catch (e) {
      throw DatabaseFailure(message: "Failed to get group activities: ${e.toString()}");
    }
  }

  @override
  Future<List<GroupActivityModel>> getAllActivities() async {
    try {
      final activities = activityBox.values.toList();
      // Sort by timestamp (newest first)
      activities.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return activities;
    } catch (e) {
      throw DatabaseFailure(message: "Failed to get all activities: ${e.toString()}");
    }
  }

  @override
  Future<GroupActivityModel?> getActivityById(String activityId) async {
    try {
      return activityBox.get(activityId);
    } catch (e) {
      throw DatabaseFailure(message: "Failed to get activity: ${e.toString()}");
    }
  }

  @override
  Future<void> addActivity(GroupActivityModel activity) async {
    try {
      await activityBox.put(activity.id, activity);
    } catch (e) {
      throw DatabaseFailure(message: "Failed to add activity: ${e.toString()}");
    }
  }

  @override
  Future<void> deleteActivity(String activityId) async {
    try {
      await activityBox.delete(activityId);
    } catch (e) {
      throw DatabaseFailure(message: "Failed to delete activity: ${e.toString()}");
    }
  }

  @override
  Future<List<GroupActivityModel>> getActivitiesByType(
    String groupId,
    GroupActivityTypeModel type,
  ) async {
    try {
      final activities = activityBox.values
          .where((activity) => activity.groupId == groupId && activity.type == type)
          .toList();
      // Sort by timestamp (newest first)
      activities.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return activities;
    } catch (e) {
      throw DatabaseFailure(message: "Failed to get activities by type: ${e.toString()}");
    }
  }

  @override
  Future<List<GroupActivityModel>> getActivitiesByDateRange(
    String groupId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final activities = activityBox.values
          .where((activity) =>
              activity.groupId == groupId &&
              activity.timestamp.isAfter(startDate.subtract(const Duration(days: 1))) &&
              activity.timestamp.isBefore(endDate.add(const Duration(days: 1))))
          .toList();
      // Sort by timestamp (newest first)
      activities.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return activities;
    } catch (e) {
      throw DatabaseFailure(message: "Failed to get activities by date range: ${e.toString()}");
    }
  }

  @override
  Future<List<GroupActivityModel>> getActivitiesByMember(
    String groupId,
    String memberId,
  ) async {
    try {
      final activities = activityBox.values
          .where((activity) => activity.groupId == groupId && activity.actorId == memberId)
          .toList();
      // Sort by timestamp (newest first)
      activities.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return activities;
    } catch (e) {
      throw DatabaseFailure(message: "Failed to get activities by member: ${e.toString()}");
    }
  }

  @override
  Future<void> clearOldActivities(DateTime cutoffDate) async {
    try {
      final oldActivities = activityBox.values
          .where((activity) => activity.timestamp.isBefore(cutoffDate))
          .toList();
      
      for (final activity in oldActivities) {
        await activityBox.delete(activity.id);
      }
    } catch (e) {
      throw DatabaseFailure(message: "Failed to clear old activities: ${e.toString()}");
    }
  }
}
