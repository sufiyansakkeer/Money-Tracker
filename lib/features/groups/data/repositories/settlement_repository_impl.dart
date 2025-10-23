import 'package:money_track/core/error/failures.dart';
import 'package:money_track/core/error/result.dart';
import 'package:money_track/features/groups/data/datasources/settlement_local_data_source.dart';
import 'package:money_track/features/groups/data/models/settlement_model.dart';
import 'package:money_track/features/groups/domain/entities/settlement_entity.dart';
import 'package:money_track/features/groups/domain/repositories/settlement_repository.dart';

class SettlementRepositoryImpl implements SettlementRepository {
  final SettlementLocalDataSource localDataSource;

  SettlementRepositoryImpl({
    required this.localDataSource,
  });

  @override
  Future<Result<List<SettlementEntity>>> getSettlements() async {
    try {
      final models = await localDataSource.getSettlements();
      final entities = models.map((model) => model.toEntity()).toList();
      return Success(entities);
    } on DatabaseFailure catch (e) {
      return Error(e);
    } catch (e) {
      return Error(DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<List<SettlementEntity>>> getSettlementsByGroup(
      String groupId) async {
    try {
      final models = await localDataSource.getSettlementsByGroup(groupId);
      final entities = models.map((model) => model.toEntity()).toList();
      return Success(entities);
    } on DatabaseFailure catch (e) {
      return Error(e);
    } catch (e) {
      return Error(DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<SettlementEntity?>> getSettlementById(
      String settlementId) async {
    try {
      final model = await localDataSource.getSettlementById(settlementId);
      final entity = model?.toEntity();
      return Success(entity);
    } on DatabaseFailure catch (e) {
      return Error(e);
    } catch (e) {
      return Error(DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<void>> addSettlement(SettlementEntity settlement) async {
    try {
      final model = SettlementModel.fromEntity(settlement);
      await localDataSource.addSettlement(model);
      return Success(null);
    } on DatabaseFailure catch (e) {
      return Error(e);
    } catch (e) {
      return Error(DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<void>> updateSettlement(SettlementEntity settlement) async {
    try {
      final model = SettlementModel.fromEntity(settlement);
      await localDataSource.updateSettlement(model);
      return Success(null);
    } on DatabaseFailure catch (e) {
      return Error(e);
    } catch (e) {
      return Error(DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<void>> deleteSettlement(String settlementId) async {
    try {
      await localDataSource.deleteSettlement(settlementId);
      return Success(null);
    } on DatabaseFailure catch (e) {
      return Error(e);
    } catch (e) {
      return Error(DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<List<SettlementEntity>>> getSettlementsByMember(
      String memberId) async {
    try {
      final models = await localDataSource.getSettlementsByMember(memberId);
      final entities = models.map((model) => model.toEntity()).toList();
      return Success(entities);
    } on DatabaseFailure catch (e) {
      return Error(e);
    } catch (e) {
      return Error(DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<List<SettlementEntity>>> getSettlementsBetweenMembers(
    String member1Id,
    String member2Id,
  ) async {
    try {
      final models = await localDataSource.getSettlementsBetweenMembers(
          member1Id, member2Id);
      final entities = models.map((model) => model.toEntity()).toList();
      return Success(entities);
    } on DatabaseFailure catch (e) {
      return Error(e);
    } catch (e) {
      return Error(DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<List<SettlementEntity>>> getPendingSettlements(
      String groupId) async {
    try {
      final models = await localDataSource.getPendingSettlements(groupId);
      final entities = models.map((model) => model.toEntity()).toList();
      return Success(entities);
    } on DatabaseFailure catch (e) {
      return Error(e);
    } catch (e) {
      return Error(DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<List<SettlementEntity>>> getConfirmedSettlements(
      String groupId) async {
    try {
      final models = await localDataSource.getConfirmedSettlements(groupId);
      final entities = models.map((model) => model.toEntity()).toList();
      return Success(entities);
    } on DatabaseFailure catch (e) {
      return Error(e);
    } catch (e) {
      return Error(DatabaseFailure(message: e.toString()));
    }
  }
}
