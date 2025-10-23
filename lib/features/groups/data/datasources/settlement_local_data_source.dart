import 'package:hive_ce/hive.dart';
import 'package:money_track/core/error/failures.dart';
import 'package:money_track/features/groups/data/models/settlement_model.dart';

abstract class SettlementLocalDataSource {
  Future<List<SettlementModel>> getSettlements();
  Future<List<SettlementModel>> getSettlementsByGroup(String groupId);
  Future<SettlementModel?> getSettlementById(String settlementId);
  Future<void> addSettlement(SettlementModel settlement);
  Future<void> updateSettlement(SettlementModel settlement);
  Future<void> deleteSettlement(String settlementId);
  Future<List<SettlementModel>> getSettlementsByMember(String memberId);
  Future<List<SettlementModel>> getSettlementsBetweenMembers(
    String member1Id,
    String member2Id,
  );
  Future<List<SettlementModel>> getPendingSettlements(String groupId);
  Future<List<SettlementModel>> getConfirmedSettlements(String groupId);
}

class SettlementLocalDataSourceImpl implements SettlementLocalDataSource {
  final Box<SettlementModel> settlementBox;

  SettlementLocalDataSourceImpl(this.settlementBox);

  @override
  Future<List<SettlementModel>> getSettlements() async {
    try {
      final settlements = settlementBox.values.toList();
      // Sort by creation date (newest first)
      settlements.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return settlements;
    } catch (e) {
      throw DatabaseFailure(message: "Failed to get settlements: ${e.toString()}");
    }
  }

  @override
  Future<List<SettlementModel>> getSettlementsByGroup(String groupId) async {
    try {
      final settlements = settlementBox.values
          .where((settlement) => settlement.groupId == groupId)
          .toList();
      // Sort by creation date (newest first)
      settlements.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return settlements;
    } catch (e) {
      throw DatabaseFailure(message: "Failed to get group settlements: ${e.toString()}");
    }
  }

  @override
  Future<SettlementModel?> getSettlementById(String settlementId) async {
    try {
      return settlementBox.get(settlementId);
    } catch (e) {
      throw DatabaseFailure(message: "Failed to get settlement: ${e.toString()}");
    }
  }

  @override
  Future<void> addSettlement(SettlementModel settlement) async {
    try {
      await settlementBox.put(settlement.id, settlement);
    } catch (e) {
      throw DatabaseFailure(message: "Failed to add settlement: ${e.toString()}");
    }
  }

  @override
  Future<void> updateSettlement(SettlementModel settlement) async {
    try {
      await settlementBox.put(settlement.id, settlement);
    } catch (e) {
      throw DatabaseFailure(message: "Failed to update settlement: ${e.toString()}");
    }
  }

  @override
  Future<void> deleteSettlement(String settlementId) async {
    try {
      await settlementBox.delete(settlementId);
    } catch (e) {
      throw DatabaseFailure(message: "Failed to delete settlement: ${e.toString()}");
    }
  }

  @override
  Future<List<SettlementModel>> getSettlementsByMember(String memberId) async {
    try {
      final settlements = settlementBox.values
          .where((settlement) =>
              settlement.payerId == memberId || settlement.receiverId == memberId)
          .toList();
      // Sort by creation date (newest first)
      settlements.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return settlements;
    } catch (e) {
      throw DatabaseFailure(message: "Failed to get member settlements: ${e.toString()}");
    }
  }

  @override
  Future<List<SettlementModel>> getSettlementsBetweenMembers(
    String member1Id,
    String member2Id,
  ) async {
    try {
      final settlements = settlementBox.values
          .where((settlement) =>
              (settlement.payerId == member1Id && settlement.receiverId == member2Id) ||
              (settlement.payerId == member2Id && settlement.receiverId == member1Id))
          .toList();
      // Sort by creation date (newest first)
      settlements.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return settlements;
    } catch (e) {
      throw DatabaseFailure(message: "Failed to get settlements between members: ${e.toString()}");
    }
  }

  @override
  Future<List<SettlementModel>> getPendingSettlements(String groupId) async {
    try {
      final settlements = settlementBox.values
          .where((settlement) =>
              settlement.groupId == groupId &&
              settlement.status == SettlementStatusModel.pending)
          .toList();
      // Sort by creation date (newest first)
      settlements.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return settlements;
    } catch (e) {
      throw DatabaseFailure(message: "Failed to get pending settlements: ${e.toString()}");
    }
  }

  @override
  Future<List<SettlementModel>> getConfirmedSettlements(String groupId) async {
    try {
      final settlements = settlementBox.values
          .where((settlement) =>
              settlement.groupId == groupId &&
              settlement.status == SettlementStatusModel.confirmed)
          .toList();
      // Sort by creation date (newest first)
      settlements.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return settlements;
    } catch (e) {
      throw DatabaseFailure(message: "Failed to get confirmed settlements: ${e.toString()}");
    }
  }
}
