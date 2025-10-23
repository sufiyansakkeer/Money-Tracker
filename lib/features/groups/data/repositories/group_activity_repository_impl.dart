import 'package:money_track/core/error/failures.dart';
import 'package:money_track/core/error/result.dart';
import 'package:money_track/features/groups/data/datasources/group_activity_local_data_source.dart';
import 'package:money_track/features/groups/data/models/group_activity_model.dart';
import 'package:money_track/features/groups/domain/entities/group_activity_entity.dart';
import 'package:money_track/features/groups/domain/repositories/group_activity_repository.dart';

class GroupActivityRepositoryImpl implements GroupActivityRepository {
  final GroupActivityLocalDataSource localDataSource;

  GroupActivityRepositoryImpl({
    required this.localDataSource,
  });

  @override
  Future<Result<List<GroupActivityEntity>>> getGroupActivities(
      String groupId) async {
    try {
      final models = await localDataSource.getGroupActivities(groupId);
      final entities = models.map((model) => model.toEntity()).toList();
      return Success(entities);
    } on DatabaseFailure catch (e) {
      return Error(e);
    } catch (e) {
      return Error(DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<List<GroupActivityEntity>>> getAllActivities() async {
    try {
      final models = await localDataSource.getAllActivities();
      final entities = models.map((model) => model.toEntity()).toList();
      return Success(entities);
    } on DatabaseFailure catch (e) {
      return Error(e);
    } catch (e) {
      return Error(DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<GroupActivityEntity?>> getActivityById(
      String activityId) async {
    try {
      final model = await localDataSource.getActivityById(activityId);
      final entity = model?.toEntity();
      return Success(entity);
    } on DatabaseFailure catch (e) {
      return Error(e);
    } catch (e) {
      return Error(DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<void>> addActivity(GroupActivityEntity activity) async {
    try {
      final model = GroupActivityModel.fromEntity(activity);
      await localDataSource.addActivity(model);
      return Success(null);
    } on DatabaseFailure catch (e) {
      return Error(e);
    } catch (e) {
      return Error(DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<void>> deleteActivity(String activityId) async {
    try {
      await localDataSource.deleteActivity(activityId);
      return Success(null);
    } on DatabaseFailure catch (e) {
      return Error(e);
    } catch (e) {
      return Error(DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<List<GroupActivityEntity>>> getActivitiesByType(
    String groupId,
    GroupActivityType type,
  ) async {
    try {
      final typeModel = _mapTypeToModel(type);
      final models =
          await localDataSource.getActivitiesByType(groupId, typeModel);
      final entities = models.map((model) => model.toEntity()).toList();
      return Success(entities);
    } on DatabaseFailure catch (e) {
      return Error(e);
    } catch (e) {
      return Error(DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<List<GroupActivityEntity>>> getActivitiesByDateRange(
    String groupId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final models = await localDataSource.getActivitiesByDateRange(
          groupId, startDate, endDate);
      final entities = models.map((model) => model.toEntity()).toList();
      return Success(entities);
    } on DatabaseFailure catch (e) {
      return Error(e);
    } catch (e) {
      return Error(DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<List<GroupActivityEntity>>> getActivitiesByMember(
    String groupId,
    String memberId,
  ) async {
    try {
      final models =
          await localDataSource.getActivitiesByMember(groupId, memberId);
      final entities = models.map((model) => model.toEntity()).toList();
      return Success(entities);
    } on DatabaseFailure catch (e) {
      return Error(e);
    } catch (e) {
      return Error(DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<void>> clearOldActivities(DateTime cutoffDate) async {
    try {
      await localDataSource.clearOldActivities(cutoffDate);
      return Success(null);
    } on DatabaseFailure catch (e) {
      return Error(e);
    } catch (e) {
      return Error(DatabaseFailure(message: e.toString()));
    }
  }

  GroupActivityTypeModel _mapTypeToModel(GroupActivityType type) {
    switch (type) {
      case GroupActivityType.expenseAdded:
        return GroupActivityTypeModel.expenseAdded;
      case GroupActivityType.expenseUpdated:
        return GroupActivityTypeModel.expenseUpdated;
      case GroupActivityType.expenseDeleted:
        return GroupActivityTypeModel.expenseDeleted;
      case GroupActivityType.settlementAdded:
        return GroupActivityTypeModel.settlementAdded;
      case GroupActivityType.settlementConfirmed:
        return GroupActivityTypeModel.settlementConfirmed;
      case GroupActivityType.settlementCancelled:
        return GroupActivityTypeModel.settlementCancelled;
      case GroupActivityType.memberAdded:
        return GroupActivityTypeModel.memberAdded;
      case GroupActivityType.memberRemoved:
        return GroupActivityTypeModel.memberRemoved;
      case GroupActivityType.groupUpdated:
        return GroupActivityTypeModel.groupUpdated;
    }
  }
}
