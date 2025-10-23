import 'package:money_track/core/error/result.dart';
import 'package:money_track/features/groups/domain/entities/group_activity_entity.dart';

abstract class GroupActivityRepository {
  Future<Result<List<GroupActivityEntity>>> getGroupActivities(String groupId);
  Future<Result<List<GroupActivityEntity>>> getAllActivities();
  Future<Result<GroupActivityEntity?>> getActivityById(String activityId);
  Future<Result<void>> addActivity(GroupActivityEntity activity);
  Future<Result<void>> deleteActivity(String activityId);
  Future<Result<List<GroupActivityEntity>>> getActivitiesByType(
    String groupId,
    GroupActivityType type,
  );
  Future<Result<List<GroupActivityEntity>>> getActivitiesByDateRange(
    String groupId,
    DateTime startDate,
    DateTime endDate,
  );
  Future<Result<List<GroupActivityEntity>>> getActivitiesByMember(
    String groupId,
    String memberId,
  );
  Future<Result<void>> clearOldActivities(DateTime cutoffDate);
}
