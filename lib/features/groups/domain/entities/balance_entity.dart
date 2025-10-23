import 'package:equatable/equatable.dart';

/// Individual balance between two members
class MemberBalance extends Equatable {
  final String memberId;
  final String memberName;
  final double amount;        // Positive = owed to this member, Negative = owes this member
  final String currency;
  final DateTime lastUpdated;

  const MemberBalance({
    required this.memberId,
    required this.memberName,
    required this.amount,
    required this.currency,
    required this.lastUpdated,
  });

  @override
  List<Object?> get props => [memberId, memberName, amount, currency, lastUpdated];

  MemberBalance copyWith({
    String? memberId,
    String? memberName,
    double? amount,
    String? currency,
    DateTime? lastUpdated,
  }) {
    return MemberBalance(
      memberId: memberId ?? this.memberId,
      memberName: memberName ?? this.memberName,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  /// Whether this member owes money
  bool get owes => amount < 0;

  /// Whether this member is owed money
  bool get isOwed => amount > 0;

  /// Absolute amount (always positive)
  double get absoluteAmount => amount.abs();
}

/// Simplified debt between two members (for debt simplification)
class SimplifiedDebt extends Equatable {
  final String debtorId;
  final String debtorName;
  final String creditorId;
  final String creditorName;
  final double amount;
  final String currency;

  const SimplifiedDebt({
    required this.debtorId,
    required this.debtorName,
    required this.creditorId,
    required this.creditorName,
    required this.amount,
    required this.currency,
  });

  @override
  List<Object?> get props => [
        debtorId,
        debtorName,
        creditorId,
        creditorName,
        amount,
        currency,
      ];

  SimplifiedDebt copyWith({
    String? debtorId,
    String? debtorName,
    String? creditorId,
    String? creditorName,
    double? amount,
    String? currency,
  }) {
    return SimplifiedDebt(
      debtorId: debtorId ?? this.debtorId,
      debtorName: debtorName ?? this.debtorName,
      creditorId: creditorId ?? this.creditorId,
      creditorName: creditorName ?? this.creditorName,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
    );
  }

  /// Get formatted description
  String get description => '$debtorName owes $creditorName $amount $currency';
}

/// Comprehensive balance entity for a group
class GroupBalanceEntity extends Equatable {
  final String groupId;
  final String groupName;
  final Map<String, List<MemberBalance>> memberBalances; // memberId -> list of balances with other members
  final List<SimplifiedDebt> simplifiedDebts;
  final double totalGroupExpenses;
  final String currency;
  final DateTime lastUpdated;
  final Map<String, double> memberTotals; // memberId -> net total (positive = owed, negative = owes)

  const GroupBalanceEntity({
    required this.groupId,
    required this.groupName,
    required this.memberBalances,
    required this.simplifiedDebts,
    required this.totalGroupExpenses,
    required this.currency,
    required this.lastUpdated,
    required this.memberTotals,
  });

  @override
  List<Object?> get props => [
        groupId,
        groupName,
        memberBalances,
        simplifiedDebts,
        totalGroupExpenses,
        currency,
        lastUpdated,
        memberTotals,
      ];

  GroupBalanceEntity copyWith({
    String? groupId,
    String? groupName,
    Map<String, List<MemberBalance>>? memberBalances,
    List<SimplifiedDebt>? simplifiedDebts,
    double? totalGroupExpenses,
    String? currency,
    DateTime? lastUpdated,
    Map<String, double>? memberTotals,
  }) {
    return GroupBalanceEntity(
      groupId: groupId ?? this.groupId,
      groupName: groupName ?? this.groupName,
      memberBalances: memberBalances ?? this.memberBalances,
      simplifiedDebts: simplifiedDebts ?? this.simplifiedDebts,
      totalGroupExpenses: totalGroupExpenses ?? this.totalGroupExpenses,
      currency: currency ?? this.currency,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      memberTotals: memberTotals ?? this.memberTotals,
    );
  }

  /// Get all members who owe money
  List<String> get debtors {
    return memberTotals.entries
        .where((entry) => entry.value < 0)
        .map((entry) => entry.key)
        .toList();
  }

  /// Get all members who are owed money
  List<String> get creditors {
    return memberTotals.entries
        .where((entry) => entry.value > 0)
        .map((entry) => entry.key)
        .toList();
  }

  /// Get net balance for a specific member
  double getMemberNetBalance(String memberId) {
    return memberTotals[memberId] ?? 0.0;
  }

  /// Get all balances for a specific member
  List<MemberBalance> getMemberBalances(String memberId) {
    return memberBalances[memberId] ?? [];
  }

  /// Check if the group has any outstanding balances
  bool get hasOutstandingBalances {
    return memberTotals.values.any((balance) => balance.abs() > 0.01);
  }

  /// Get total amount owed in the group
  double get totalAmountOwed {
    return memberTotals.values
        .where((balance) => balance > 0)
        .fold(0.0, (sum, balance) => sum + balance);
  }

  /// Get total debt in the group
  double get totalDebt {
    return memberTotals.values
        .where((balance) => balance < 0)
        .fold(0.0, (sum, balance) => sum + balance.abs());
  }

  /// Check if balances are balanced (total owed = total debt)
  bool get isBalanced {
    return (totalAmountOwed - totalDebt).abs() < 0.01;
  }

  /// Get number of transactions needed to settle all debts
  int get transactionsToSettle {
    return simplifiedDebts.length;
  }
}
