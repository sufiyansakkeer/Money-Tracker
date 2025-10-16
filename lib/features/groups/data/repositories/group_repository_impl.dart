import 'package:money_track/core/error/failures.dart';
import 'package:money_track/core/error/result.dart';
import 'package:money_track/features/groups/data/datasources/group_local_data_source.dart';
import 'package:money_track/features/groups/data/models/group_model.dart';
import 'package:money_track/features/groups/domain/entities/group_entity.dart';
import 'package:money_track/features/groups/domain/repositories/group_repository.dart';

class GroupRepositoryImpl implements GroupRepository {
  final GroupLocalDataSource localDataSource;

  GroupRepositoryImpl({required this.localDataSource});

  @override
  Future<Result<void>> createGroup(GroupEntity group) async {
    try {
      final groupModel = GroupModel.fromEntity(group);
      await localDataSource.createGroup(groupModel);
      return const Success(null);
    } catch (e) {
      return Error(DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<void>> deleteGroup(String groupId) async {
    try {
      await localDataSource.deleteGroup(groupId);
      return const Success(null);
    } catch (e) {
      return Error(DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<List<GroupEntity>>> getGroups() async {
    try {
      final groupModels = await localDataSource.getGroups();
      final groups = groupModels.map((model) => model.toEntity()).toList();
      return Success(groups);
    } catch (e) {
      return Error(DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<void>> updateGroup(GroupEntity group) async {
    try {
      final groupModel = GroupModel.fromEntity(group);
      await localDataSource.updateGroup(groupModel);
      return const Success(null);
    } catch (e) {
      return Error(DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<GroupEntity?>> getGroupById(String groupId) async {
    try {
      final groupModel = await localDataSource.getGroupById(groupId);
      if (groupModel == null) {
        return const Success(null);
      }
      return Success(groupModel.toEntity());
    } catch (e) {
      return Error(DatabaseFailure(message: e.toString()));
    }
  }
}