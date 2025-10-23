import 'package:money_track/core/error/result.dart';
import 'package:money_track/core/error/failures.dart';
import 'package:money_track/core/extensions/result_extensions.dart';
import 'package:money_track/features/groups/domain/entities/balance_entity.dart';
import 'package:money_track/features/groups/domain/entities/settlement_entity.dart';
import 'package:money_track/features/groups/domain/usecases/balance/calculate_group_balance_usecase.dart';
import 'package:money_track/features/groups/domain/usecases/settlement/add_settlement_usecase.dart';
import 'package:money_track/features/groups/domain/repositories/settlement_repository.dart';

/// Service for managing group balances and settlements
class BalanceService {
  final CalculateGroupBalanceUseCase calculateGroupBalanceUseCase;
  final AddSettlementUseCase addSettlementUseCase;
  final SettlementRepository settlementRepository;

  BalanceService({
    required this.calculateGroupBalanceUseCase,
    required this.addSettlementUseCase,
    required this.settlementRepository,
  });

  /// Get current balance for a group
  Future<Result<GroupBalanceEntity>> getGroupBalance(
    String groupId, {
    String? currency,
  }) async {
    return await calculateGroupBalanceUseCase(
      params: CalculateGroupBalanceParams(
        groupId: groupId,
        currency: currency,
      ),
    );
  }

  /// Get balance between two specific members
  Future<Result<double>> getBalanceBetweenMembers(
    String groupId,
    String member1Id,
    String member2Id, {
    String? currency,
  }) async {
    final balanceResult = await getGroupBalance(groupId, currency: currency);
    if (balanceResult.isError) {
      return Error(balanceResult.error!);
    }

    final balance = balanceResult.data!;
    final memberBalance = balance
        .getMemberBalances(member1Id)
        .where((b) => b.memberId == member2Id)
        .fold(0.0, (sum, b) => sum + b.amount);

    return Success(memberBalance);
  }

  /// Get all debts for a member across groups
  Future<Result<List<SimplifiedDebt>>> getMemberDebts(
    String memberId,
    List<String> groupIds, {
    String? currency,
  }) async {
    final allDebts = <SimplifiedDebt>[];

    for (final groupId in groupIds) {
      final balanceResult = await getGroupBalance(groupId, currency: currency);
      if (balanceResult.isSuccess) {
        final debts = balanceResult.data!.simplifiedDebts
            .where((debt) => debt.debtorId == memberId)
            .toList();
        allDebts.addAll(debts);
      }
    }

    return Success(allDebts);
  }

  /// Get all credits for a member across groups
  Future<Result<List<SimplifiedDebt>>> getMemberCredits(
    String memberId,
    List<String> groupIds, {
    String? currency,
  }) async {
    final allCredits = <SimplifiedDebt>[];

    for (final groupId in groupIds) {
      final balanceResult = await getGroupBalance(groupId, currency: currency);
      if (balanceResult.isSuccess) {
        final credits = balanceResult.data!.simplifiedDebts
            .where((debt) => debt.creditorId == memberId)
            .toList();
        allCredits.addAll(credits);
      }
    }

    return Success(allCredits);
  }

  /// Record a settlement between members
  Future<Result<void>> recordSettlement(SettlementEntity settlement) async {
    return await addSettlementUseCase(
      params: AddSettlementParams(settlement: settlement),
    );
  }

  /// Confirm a pending settlement
  Future<Result<void>> confirmSettlement(
    String settlementId,
    String confirmerId,
  ) async {
    final settlementResult =
        await settlementRepository.getSettlementById(settlementId);
    if (settlementResult.isError) {
      return Error(settlementResult.error!);
    }

    final settlement = settlementResult.data;
    if (settlement == null) {
      return Error(DatabaseFailure(message: 'Settlement not found'));
    }

    final confirmedSettlement = settlement.copyWith(
      status: SettlementStatus.confirmed,
      confirmedAt: DateTime.now(),
      confirmedBy: confirmerId,
      updatedAt: DateTime.now(),
    );

    return await settlementRepository.updateSettlement(confirmedSettlement);
  }

  /// Cancel a pending settlement
  Future<Result<void>> cancelSettlement(String settlementId) async {
    final settlementResult =
        await settlementRepository.getSettlementById(settlementId);
    if (settlementResult.isError) {
      return Error(settlementResult.error!);
    }

    final settlement = settlementResult.data;
    if (settlement == null) {
      return Error(DatabaseFailure(message: 'Settlement not found'));
    }

    final cancelledSettlement = settlement.copyWith(
      status: SettlementStatus.cancelled,
      updatedAt: DateTime.now(),
    );

    return await settlementRepository.updateSettlement(cancelledSettlement);
  }

  /// Get settlement history for a group
  Future<Result<List<SettlementEntity>>> getGroupSettlements(
      String groupId) async {
    return await settlementRepository.getSettlementsByGroup(groupId);
  }

  /// Get pending settlements for a group
  Future<Result<List<SettlementEntity>>> getPendingSettlements(
      String groupId) async {
    return await settlementRepository.getPendingSettlements(groupId);
  }

  /// Get settlements between two members
  Future<Result<List<SettlementEntity>>> getSettlementsBetweenMembers(
    String member1Id,
    String member2Id,
  ) async {
    return await settlementRepository.getSettlementsBetweenMembers(
        member1Id, member2Id);
  }

  /// Calculate total amount owed by a member
  Future<Result<double>> getTotalOwedByMember(
    String memberId,
    List<String> groupIds, {
    String? currency,
  }) async {
    final debtsResult =
        await getMemberDebts(memberId, groupIds, currency: currency);
    if (debtsResult.isError) {
      return Error(debtsResult.error!);
    }

    final totalOwed =
        debtsResult.data!.fold(0.0, (sum, debt) => sum + debt.amount);
    return Success(totalOwed);
  }

  /// Calculate total amount owed to a member
  Future<Result<double>> getTotalOwedToMember(
    String memberId,
    List<String> groupIds, {
    String? currency,
  }) async {
    final creditsResult =
        await getMemberCredits(memberId, groupIds, currency: currency);
    if (creditsResult.isError) {
      return Error(creditsResult.error!);
    }

    final totalOwedTo =
        creditsResult.data!.fold(0.0, (sum, credit) => sum + credit.amount);
    return Success(totalOwedTo);
  }
}
