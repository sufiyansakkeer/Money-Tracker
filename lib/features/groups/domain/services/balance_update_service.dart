import 'dart:async';
import 'package:money_track/core/error/result.dart';
import 'package:money_track/core/extensions/result_extensions.dart';
import 'package:money_track/features/groups/domain/entities/balance_entity.dart';
import 'package:money_track/features/groups/domain/entities/shared_expense_entity.dart';
import 'package:money_track/features/groups/domain/entities/settlement_entity.dart';
import 'package:money_track/features/groups/domain/services/balance_service.dart';

/// Service for real-time balance updates and notifications
class BalanceUpdateService {
  final BalanceService balanceService;
  final Map<String, StreamController<GroupBalanceEntity>> _balanceStreams = {};
  final Map<String, GroupBalanceEntity> _cachedBalances = {};

  BalanceUpdateService({
    required this.balanceService,
  });

  /// Get a stream of balance updates for a group
  Stream<GroupBalanceEntity> getBalanceStream(String groupId) {
    if (!_balanceStreams.containsKey(groupId)) {
      _balanceStreams[groupId] =
          StreamController<GroupBalanceEntity>.broadcast();
      _initializeGroupBalance(groupId);
    }
    return _balanceStreams[groupId]!.stream;
  }

  /// Initialize balance for a group
  Future<void> _initializeGroupBalance(String groupId) async {
    final balanceResult = await balanceService.getGroupBalance(groupId);
    if (balanceResult.isSuccess) {
      final balance = balanceResult.data!;
      _cachedBalances[groupId] = balance;
      _balanceStreams[groupId]?.add(balance);
    }
  }

  /// Update balance after expense is added
  Future<void> onExpenseAdded(SharedExpenseEntity expense) async {
    await _updateGroupBalance(expense.groupId);
  }

  /// Update balance after expense is updated
  Future<void> onExpenseUpdated(SharedExpenseEntity expense) async {
    await _updateGroupBalance(expense.groupId);
  }

  /// Update balance after expense is deleted
  Future<void> onExpenseDeleted(String groupId) async {
    await _updateGroupBalance(groupId);
  }

  /// Update balance after settlement is added
  Future<void> onSettlementAdded(SettlementEntity settlement) async {
    await _updateGroupBalance(settlement.groupId);
  }

  /// Update balance after settlement is confirmed
  Future<void> onSettlementConfirmed(SettlementEntity settlement) async {
    await _updateGroupBalance(settlement.groupId);
  }

  /// Update balance after settlement is cancelled
  Future<void> onSettlementCancelled(SettlementEntity settlement) async {
    await _updateGroupBalance(settlement.groupId);
  }

  /// Update balance for a specific group
  Future<void> _updateGroupBalance(String groupId) async {
    final balanceResult = await balanceService.getGroupBalance(groupId);
    if (balanceResult.isSuccess) {
      final balance = balanceResult.data!;
      final previousBalance = _cachedBalances[groupId];

      // Only update if balance has actually changed
      if (previousBalance == null ||
          !_balancesEqual(previousBalance, balance)) {
        _cachedBalances[groupId] = balance;
        _balanceStreams[groupId]?.add(balance);
      }
    }
  }

  /// Check if two balances are equal (for optimization)
  bool _balancesEqual(
      GroupBalanceEntity balance1, GroupBalanceEntity balance2) {
    if (balance1.totalGroupExpenses != balance2.totalGroupExpenses)
      return false;
    if (balance1.memberTotals.length != balance2.memberTotals.length)
      return false;

    for (final entry in balance1.memberTotals.entries) {
      final otherValue = balance2.memberTotals[entry.key];
      if (otherValue == null || (entry.value - otherValue).abs() > 0.01) {
        return false;
      }
    }

    return true;
  }

  /// Get cached balance for a group (if available)
  GroupBalanceEntity? getCachedBalance(String groupId) {
    return _cachedBalances[groupId];
  }

  /// Force refresh balance for a group
  Future<void> refreshGroupBalance(String groupId) async {
    await _updateGroupBalance(groupId);
  }

  /// Get balance summary for multiple groups
  Future<Result<Map<String, GroupBalanceEntity>>> getMultiGroupBalances(
    List<String> groupIds,
  ) async {
    final balances = <String, GroupBalanceEntity>{};

    for (final groupId in groupIds) {
      final balanceResult = await balanceService.getGroupBalance(groupId);
      if (balanceResult.isSuccess) {
        balances[groupId] = balanceResult.data!;
        _cachedBalances[groupId] = balanceResult.data!;
      }
    }

    return Success(balances);
  }

  /// Get member's total balance across all groups
  Future<Result<double>> getMemberTotalBalance(
    String memberId,
    List<String> groupIds,
  ) async {
    double totalBalance = 0.0;

    for (final groupId in groupIds) {
      final balanceResult = await balanceService.getGroupBalance(groupId);
      if (balanceResult.isSuccess) {
        final balance = balanceResult.data!;
        totalBalance += balance.memberTotals[memberId] ?? 0.0;
      }
    }

    return Success(totalBalance);
  }

  /// Get member's debt summary across all groups
  Future<Result<MemberDebtSummary>> getMemberDebtSummary(
    String memberId,
    List<String> groupIds,
  ) async {
    double totalOwed = 0.0;
    double totalOwedTo = 0.0;
    final debtsByGroup = <String, List<SimplifiedDebt>>{};
    final creditsByGroup = <String, List<SimplifiedDebt>>{};

    for (final groupId in groupIds) {
      final balanceResult = await balanceService.getGroupBalance(groupId);
      if (balanceResult.isSuccess) {
        final balance = balanceResult.data!;

        final debts = balance.simplifiedDebts
            .where((debt) => debt.debtorId == memberId)
            .toList();
        final credits = balance.simplifiedDebts
            .where((debt) => debt.creditorId == memberId)
            .toList();

        if (debts.isNotEmpty) {
          debtsByGroup[groupId] = debts;
          totalOwed += debts.fold(0.0, (sum, debt) => sum + debt.amount);
        }

        if (credits.isNotEmpty) {
          creditsByGroup[groupId] = credits;
          totalOwedTo +=
              credits.fold(0.0, (sum, credit) => sum + credit.amount);
        }
      }
    }

    return Success(MemberDebtSummary(
      memberId: memberId,
      totalOwed: totalOwed,
      totalOwedTo: totalOwedTo,
      netBalance: totalOwedTo - totalOwed,
      debtsByGroup: debtsByGroup,
      creditsByGroup: creditsByGroup,
    ));
  }

  /// Dispose of resources
  void dispose() {
    for (final controller in _balanceStreams.values) {
      controller.close();
    }
    _balanceStreams.clear();
    _cachedBalances.clear();
  }
}

/// Summary of a member's debts and credits across groups
class MemberDebtSummary {
  final String memberId;
  final double totalOwed;
  final double totalOwedTo;
  final double netBalance;
  final Map<String, List<SimplifiedDebt>> debtsByGroup;
  final Map<String, List<SimplifiedDebt>> creditsByGroup;

  MemberDebtSummary({
    required this.memberId,
    required this.totalOwed,
    required this.totalOwedTo,
    required this.netBalance,
    required this.debtsByGroup,
    required this.creditsByGroup,
  });

  bool get isInDebt => netBalance < 0;
  bool get isOwedMoney => netBalance > 0;
  bool get isBalanced => netBalance.abs() < 0.01;
}
