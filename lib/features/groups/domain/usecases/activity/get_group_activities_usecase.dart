import 'package:money_track/core/use_cases/use_case.dart';
import 'package:money_track/core/error/result.dart';
import 'package:money_track/features/groups/domain/entities/group_activity_entity.dart';
import 'package:money_track/features/groups/domain/repositories/group_activity_repository.dart';

class GetGroupActivitiesUseCase
    implements
        UseCase<Result<List<GroupActivityEntity>>, GetGroupActivitiesParams> {
  final GroupActivityRepository repository;

  GetGroupActivitiesUseCase({
    required this.repository,
  });

  @override
  Future<Result<List<GroupActivityEntity>>> call(
      {GetGroupActivitiesParams? params}) async {
    if (params == null) {
      throw ArgumentError('GetGroupActivitiesParams cannot be null');
    }
    if (params.dateRange != null) {
      return await repository.getActivitiesByDateRange(
        params.groupId,
        params.dateRange!.start,
        params.dateRange!.end,
      );
    }

    if (params.memberId != null) {
      return await repository.getActivitiesByMember(
          params.groupId, params.memberId!);
    }

    if (params.activityType != null) {
      return await repository.getActivitiesByType(
          params.groupId, params.activityType!);
    }

    return await repository.getGroupActivities(params.groupId);
  }
}

class GetGroupActivitiesParams {
  final String groupId;
  final DateTimeRange? dateRange;
  final String? memberId;
  final GroupActivityType? activityType;

  GetGroupActivitiesParams({
    required this.groupId,
    this.dateRange,
    this.memberId,
    this.activityType,
  });
}

class DateTimeRange {
  final DateTime start;
  final DateTime end;

  DateTimeRange({
    required this.start,
    required this.end,
  });
}
