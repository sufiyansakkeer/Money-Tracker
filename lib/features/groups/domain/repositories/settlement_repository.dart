import 'package:money_track/core/error/result.dart';
import 'package:money_track/features/groups/domain/entities/settlement_entity.dart';

abstract class SettlementRepository {
  Future<Result<List<SettlementEntity>>> getSettlements();
  Future<Result<List<SettlementEntity>>> getSettlementsByGroup(String groupId);
  Future<Result<SettlementEntity?>> getSettlementById(String settlementId);
  Future<Result<void>> addSettlement(SettlementEntity settlement);
  Future<Result<void>> updateSettlement(SettlementEntity settlement);
  Future<Result<void>> deleteSettlement(String settlementId);
  Future<Result<List<SettlementEntity>>> getSettlementsByMember(
      String memberId);
  Future<Result<List<SettlementEntity>>> getSettlementsBetweenMembers(
    String member1Id,
    String member2Id,
  );
  Future<Result<List<SettlementEntity>>> getPendingSettlements(String groupId);
  Future<Result<List<SettlementEntity>>> getConfirmedSettlements(
      String groupId);
}
