import 'package:money_track/features/groups/domain/entities/balance_entity.dart';
import 'package:money_track/features/groups/domain/entities/shared_expense_entity.dart';
import 'package:money_track/features/groups/domain/entities/settlement_entity.dart';
import 'package:money_track/features/groups/domain/entities/group_entity.dart';

/// Comprehensive balance calculation utility for expense splitting
class BalanceCalculator {
  /// Calculate group balances from expenses and settlements
  static GroupBalanceEntity calculateGroupBalance({
    required GroupEntity group,
    required List<SharedExpenseEntity> expenses,
    required List<SettlementEntity> settlements,
    required String currency,
  }) {
    final memberBalances = <String, List<MemberBalance>>{};
    final memberTotals = <String, double>{};

    // Initialize member totals
    for (final member in group.members) {
      memberTotals[member.id] = 0.0;
      memberBalances[member.id] = [];
    }

    // Calculate balances from expenses
    double totalGroupExpenses = 0.0;
    for (final expense in expenses) {
      totalGroupExpenses += expense.totalAmount;
      _processExpenseBalances(expense, memberTotals);
    }

    // Apply settlements
    for (final settlement in settlements) {
      if (settlement.isConfirmed) {
        _processSettlementBalances(settlement, memberTotals);
      }
    }

    // Calculate pairwise balances
    _calculatePairwiseBalances(
        group.members, memberTotals, memberBalances, currency);

    // Calculate simplified debts
    final simplifiedDebts =
        _simplifyDebts(group.members, memberTotals, currency);

    return GroupBalanceEntity(
      groupId: group.id,
      groupName: group.name,
      memberBalances: memberBalances,
      simplifiedDebts: simplifiedDebts,
      totalGroupExpenses: totalGroupExpenses,
      currency: currency,
      lastUpdated: DateTime.now(),
      memberTotals: memberTotals,
    );
  }

  /// Process expense to update member balances
  static void _processExpenseBalances(
    SharedExpenseEntity expense,
    Map<String, double> memberTotals,
  ) {
    for (final participant in expense.participants) {
      // Add what they owe
      memberTotals[participant.memberId] =
          (memberTotals[participant.memberId] ?? 0.0) - participant.amount;

      // Add what they paid
      memberTotals[participant.memberId] =
          (memberTotals[participant.memberId] ?? 0.0) + participant.paidAmount;
    }
  }

  /// Process settlement to update member balances
  static void _processSettlementBalances(
    SettlementEntity settlement,
    Map<String, double> memberTotals,
  ) {
    // Payer's balance decreases (they paid money)
    memberTotals[settlement.payerId] =
        (memberTotals[settlement.payerId] ?? 0.0) - settlement.amount;

    // Receiver's balance increases (they received money)
    memberTotals[settlement.receiverId] =
        (memberTotals[settlement.receiverId] ?? 0.0) + settlement.amount;
  }

  /// Calculate pairwise balances between members
  static void _calculatePairwiseBalances(
    List<GroupMember> members,
    Map<String, double> memberTotals,
    Map<String, List<MemberBalance>> memberBalances,
    String currency,
  ) {
    for (int i = 0; i < members.length; i++) {
      for (int j = i + 1; j < members.length; j++) {
        final member1 = members[i];
        final member2 = members[j];

        final balance1 = memberTotals[member1.id] ?? 0.0;
        final balance2 = memberTotals[member2.id] ?? 0.0;

        // Calculate net balance between the two members
        final netBalance = balance1 - balance2;

        if (netBalance.abs() > 0.01) {
          // Only include significant balances
          // Add balance for member1
          memberBalances[member1.id]!.add(MemberBalance(
            memberId: member2.id,
            memberName: member2.name,
            amount: netBalance,
            currency: currency,
            lastUpdated: DateTime.now(),
          ));

          // Add opposite balance for member2
          memberBalances[member2.id]!.add(MemberBalance(
            memberId: member1.id,
            memberName: member1.name,
            amount: -netBalance,
            currency: currency,
            lastUpdated: DateTime.now(),
          ));
        }
      }
    }
  }

  /// Simplify debts using debt minimization algorithm
  static List<SimplifiedDebt> _simplifyDebts(
    List<GroupMember> members,
    Map<String, double> memberTotals,
    String currency,
  ) {
    final debts = <SimplifiedDebt>[];

    // Create lists of creditors and debtors
    final creditors = <MapEntry<GroupMember, double>>[];
    final debtors = <MapEntry<GroupMember, double>>[];

    for (final member in members) {
      final balance = memberTotals[member.id] ?? 0.0;
      if (balance > 0.01) {
        creditors.add(MapEntry(member, balance));
      } else if (balance < -0.01) {
        debtors.add(MapEntry(member, balance.abs()));
      }
    }

    // Sort by amount (largest first)
    creditors.sort((a, b) => b.value.compareTo(a.value));
    debtors.sort((a, b) => b.value.compareTo(a.value));

    // Minimize transactions using greedy algorithm
    int creditorIndex = 0;
    int debtorIndex = 0;

    while (creditorIndex < creditors.length && debtorIndex < debtors.length) {
      final creditor = creditors[creditorIndex];
      final debtor = debtors[debtorIndex];

      final amount =
          creditor.value < debtor.value ? creditor.value : debtor.value;

      debts.add(SimplifiedDebt(
        debtorId: debtor.key.id,
        debtorName: debtor.key.name,
        creditorId: creditor.key.id,
        creditorName: creditor.key.name,
        amount: amount,
        currency: currency,
      ));

      // Update remaining amounts
      creditors[creditorIndex] =
          MapEntry(creditor.key, creditor.value - amount);
      debtors[debtorIndex] = MapEntry(debtor.key, debtor.value - amount);

      // Move to next creditor/debtor if current one is settled
      if (creditors[creditorIndex].value < 0.01) {
        creditorIndex++;
      }
      if (debtors[debtorIndex].value < 0.01) {
        debtorIndex++;
      }
    }

    return debts;
  }

  /// Calculate balance for a specific member across all groups
  static double calculateMemberTotalBalance(
    String memberId,
    List<GroupBalanceEntity> groupBalances,
  ) {
    return groupBalances.fold(0.0, (total, groupBalance) {
      return total + (groupBalance.memberTotals[memberId] ?? 0.0);
    });
  }

  /// Get all debts for a specific member
  static List<SimplifiedDebt> getMemberDebts(
    String memberId,
    List<GroupBalanceEntity> groupBalances,
  ) {
    final debts = <SimplifiedDebt>[];
    for (final groupBalance in groupBalances) {
      debts.addAll(
        groupBalance.simplifiedDebts.where((debt) => debt.debtorId == memberId),
      );
    }
    return debts;
  }

  /// Get all credits for a specific member
  static List<SimplifiedDebt> getMemberCredits(
    String memberId,
    List<GroupBalanceEntity> groupBalances,
  ) {
    final credits = <SimplifiedDebt>[];
    for (final groupBalance in groupBalances) {
      credits.addAll(
        groupBalance.simplifiedDebts
            .where((debt) => debt.creditorId == memberId),
      );
    }
    return credits;
  }

  /// Check if two members have any outstanding balance
  static double getBalanceBetweenMembers(
    String member1Id,
    String member2Id,
    GroupBalanceEntity groupBalance,
  ) {
    final member1Balances = groupBalance.getMemberBalances(member1Id);
    final balanceToMember2 = member1Balances
        .where((balance) => balance.memberId == member2Id)
        .fold(0.0, (sum, balance) => sum + balance.amount);

    return balanceToMember2;
  }

  /// Calculate net balance for a member (what they owe minus what they're owed)
  static double calculateMemberNetBalance(
    String memberId,
    List<GroupBalanceEntity> groupBalances,
  ) {
    double totalOwed = 0.0;
    double totalOwedTo = 0.0;

    for (final groupBalance in groupBalances) {
      // What they owe
      totalOwed += groupBalance.simplifiedDebts
          .where((debt) => debt.debtorId == memberId)
          .fold(0.0, (sum, debt) => sum + debt.amount);

      // What they're owed
      totalOwedTo += groupBalance.simplifiedDebts
          .where((debt) => debt.creditorId == memberId)
          .fold(0.0, (sum, debt) => sum + debt.amount);
    }

    return totalOwedTo -
        totalOwed; // Positive means they're owed money, negative means they owe money
  }

  /// Validate balance calculations
  static bool validateGroupBalance(GroupBalanceEntity groupBalance) {
    // Sum of all member totals should be close to zero (within rounding errors)
    final totalBalance = groupBalance.memberTotals.values
        .fold(0.0, (sum, balance) => sum + balance);

    // Allow for small rounding differences
    return totalBalance.abs() < 0.01;
  }
}
