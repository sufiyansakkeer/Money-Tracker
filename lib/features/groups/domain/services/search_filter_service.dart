import 'package:money_track/features/groups/domain/entities/shared_expense_entity.dart';
import 'package:money_track/features/groups/domain/entities/settlement_entity.dart';
import 'package:money_track/features/groups/domain/entities/group_activity_entity.dart';
import 'package:money_track/features/groups/domain/entities/group_entity.dart';
import 'package:money_track/data/models/category_model.dart';

enum SortBy {
  date,
  amount,
  description,
  category,
  paidBy,
}

enum SortOrder {
  ascending,
  descending,
}

class ExpenseFilter {
  final DateTime? startDate;
  final DateTime? endDate;
  final double? minAmount;
  final double? maxAmount;
  final List<String>? categories;
  final List<String>? paidByMembers;
  final List<EnhancedSplitType>? splitTypes;
  final String? searchQuery;
  final SortBy sortBy;
  final SortOrder sortOrder;

  const ExpenseFilter({
    this.startDate,
    this.endDate,
    this.minAmount,
    this.maxAmount,
    this.categories,
    this.paidByMembers,
    this.splitTypes,
    this.searchQuery,
    this.sortBy = SortBy.date,
    this.sortOrder = SortOrder.descending,
  });

  ExpenseFilter copyWith({
    DateTime? startDate,
    DateTime? endDate,
    double? minAmount,
    double? maxAmount,
    List<String>? categories,
    List<String>? paidByMembers,
    List<EnhancedSplitType>? splitTypes,
    String? searchQuery,
    SortBy? sortBy,
    SortOrder? sortOrder,
  }) {
    return ExpenseFilter(
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      minAmount: minAmount ?? this.minAmount,
      maxAmount: maxAmount ?? this.maxAmount,
      categories: categories ?? this.categories,
      paidByMembers: paidByMembers ?? this.paidByMembers,
      splitTypes: splitTypes ?? this.splitTypes,
      searchQuery: searchQuery ?? this.searchQuery,
      sortBy: sortBy ?? this.sortBy,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }
}

class SettlementFilter {
  final DateTime? startDate;
  final DateTime? endDate;
  final double? minAmount;
  final double? maxAmount;
  final List<SettlementStatus>? statuses;
  final List<PaymentMethod>? paymentMethods;
  final List<String>? fromMembers;
  final List<String>? toMembers;
  final String? searchQuery;
  final SortBy sortBy;
  final SortOrder sortOrder;

  const SettlementFilter({
    this.startDate,
    this.endDate,
    this.minAmount,
    this.maxAmount,
    this.statuses,
    this.paymentMethods,
    this.fromMembers,
    this.toMembers,
    this.searchQuery,
    this.sortBy = SortBy.date,
    this.sortOrder = SortOrder.descending,
  });

  SettlementFilter copyWith({
    DateTime? startDate,
    DateTime? endDate,
    double? minAmount,
    double? maxAmount,
    List<SettlementStatus>? statuses,
    List<PaymentMethod>? paymentMethods,
    List<String>? fromMembers,
    List<String>? toMembers,
    String? searchQuery,
    SortBy? sortBy,
    SortOrder? sortOrder,
  }) {
    return SettlementFilter(
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      minAmount: minAmount ?? this.minAmount,
      maxAmount: maxAmount ?? this.maxAmount,
      statuses: statuses ?? this.statuses,
      paymentMethods: paymentMethods ?? this.paymentMethods,
      fromMembers: fromMembers ?? this.fromMembers,
      toMembers: toMembers ?? this.toMembers,
      searchQuery: searchQuery ?? this.searchQuery,
      sortBy: sortBy ?? this.sortBy,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }
}

class SearchFilterService {
  /// Filter and search shared expenses
  List<SharedExpenseEntity> filterExpenses(
    List<SharedExpenseEntity> expenses,
    ExpenseFilter filter,
  ) {
    var filteredExpenses = expenses.where((expense) {
      // Date range filter
      if (filter.startDate != null &&
          expense.createdAt.isBefore(filter.startDate!)) {
        return false;
      }
      if (filter.endDate != null &&
          expense.createdAt.isAfter(filter.endDate!)) {
        return false;
      }

      // Amount range filter
      if (filter.minAmount != null && expense.totalAmount < filter.minAmount!) {
        return false;
      }
      if (filter.maxAmount != null && expense.totalAmount > filter.maxAmount!) {
        return false;
      }

      // Category filter
      if (filter.categories != null && filter.categories!.isNotEmpty) {
        if (expense.category == null ||
            !filter.categories!.contains(expense.category!.id)) {
          return false;
        }
      }

      // Paid by member filter
      if (filter.paidByMembers != null && filter.paidByMembers!.isNotEmpty) {
        if (!filter.paidByMembers!.contains(expense.primaryPayer?.memberId)) {
          return false;
        }
      }

      // Split type filter
      if (filter.splitTypes != null && filter.splitTypes!.isNotEmpty) {
        if (!filter.splitTypes!.contains(expense.splitType)) {
          return false;
        }
      }

      // Search query filter
      if (filter.searchQuery != null && filter.searchQuery!.isNotEmpty) {
        final query = filter.searchQuery!.toLowerCase();
        final matchesDescription =
            expense.description?.toLowerCase().contains(query) ?? false;
        final matchesTitle = expense.title.toLowerCase().contains(query);
        final matchesCategory =
            expense.category.categoryName.toLowerCase().contains(query);
        final matchesPaidBy =
            expense.primaryPayer?.memberName.toLowerCase().contains(query) ??
                false;
        final matchesParticipants = expense.participants.any(
          (p) => p.memberName.toLowerCase().contains(query),
        );

        if (!matchesDescription &&
            !matchesCategory &&
            !matchesPaidBy &&
            !matchesParticipants) {
          return false;
        }
      }

      return true;
    }).toList();

    // Sort expenses
    filteredExpenses.sort((a, b) {
      int comparison = 0;

      switch (filter.sortBy) {
        case SortBy.date:
          comparison = a.createdAt.compareTo(b.createdAt);
          break;
        case SortBy.amount:
          comparison = a.totalAmount.compareTo(b.totalAmount);
          break;
        case SortBy.description:
          comparison = (a.description ?? '').compareTo(b.description ?? '');
          break;
        case SortBy.category:
          final aCategory = a.category.categoryName;
          final bCategory = b.category.categoryName;
          comparison = aCategory.compareTo(bCategory);
          break;
        case SortBy.paidBy:
          final aPaidBy = a.primaryPayer?.memberName ?? '';
          final bPaidBy = b.primaryPayer?.memberName ?? '';
          comparison = aPaidBy.compareTo(bPaidBy);
          break;
      }

      return filter.sortOrder == SortOrder.ascending ? comparison : -comparison;
    });

    return filteredExpenses;
  }

  /// Filter and search settlements
  List<SettlementEntity> filterSettlements(
    List<SettlementEntity> settlements,
    SettlementFilter filter,
  ) {
    var filteredSettlements = settlements.where((settlement) {
      // Date range filter
      if (filter.startDate != null &&
          settlement.createdAt.isBefore(filter.startDate!)) {
        return false;
      }
      if (filter.endDate != null &&
          settlement.createdAt.isAfter(filter.endDate!)) {
        return false;
      }

      // Amount range filter
      if (filter.minAmount != null && settlement.amount < filter.minAmount!) {
        return false;
      }
      if (filter.maxAmount != null && settlement.amount > filter.maxAmount!) {
        return false;
      }

      // Status filter
      if (filter.statuses != null && filter.statuses!.isNotEmpty) {
        if (!filter.statuses!.contains(settlement.status)) {
          return false;
        }
      }

      // Payment method filter
      if (filter.paymentMethods != null && filter.paymentMethods!.isNotEmpty) {
        if (!filter.paymentMethods!.contains(settlement.paymentMethod)) {
          return false;
        }
      }

      // From member filter
      if (filter.fromMembers != null && filter.fromMembers!.isNotEmpty) {
        if (!filter.fromMembers!.contains(settlement.payerId)) {
          return false;
        }
      }

      // To member filter
      if (filter.toMembers != null && filter.toMembers!.isNotEmpty) {
        if (!filter.toMembers!.contains(settlement.receiverId)) {
          return false;
        }
      }

      // Search query filter
      if (filter.searchQuery != null && filter.searchQuery!.isNotEmpty) {
        final query = filter.searchQuery!.toLowerCase();
        final matchesDescription =
            settlement.description?.toLowerCase().contains(query) ?? false;
        final matchesFromMember =
            settlement.payerName.toLowerCase().contains(query);
        final matchesToMember =
            settlement.receiverName.toLowerCase().contains(query);

        if (!matchesDescription && !matchesFromMember && !matchesToMember) {
          return false;
        }
      }

      return true;
    }).toList();

    // Sort settlements
    filteredSettlements.sort((a, b) {
      int comparison = 0;

      switch (filter.sortBy) {
        case SortBy.date:
          comparison = a.createdAt.compareTo(b.createdAt);
          break;
        case SortBy.amount:
          comparison = a.amount.compareTo(b.amount);
          break;
        case SortBy.description:
          final aDesc = a.description ?? '';
          final bDesc = b.description ?? '';
          comparison = aDesc.compareTo(bDesc);
          break;
        case SortBy.category:
          // Not applicable for settlements, sort by status instead
          comparison = a.status.name.compareTo(b.status.name);
          break;
        case SortBy.paidBy:
          // Sort by from member for settlements
          comparison = a.payerName.compareTo(b.payerName);
          break;
      }

      return filter.sortOrder == SortOrder.ascending ? comparison : -comparison;
    });

    return filteredSettlements;
  }

  /// Search groups by name or member names
  List<GroupEntity> searchGroups(
    List<GroupEntity> groups,
    String query,
  ) {
    if (query.isEmpty) return groups;

    final lowerQuery = query.toLowerCase();
    return groups.where((group) {
      final matchesName = group.name.toLowerCase().contains(lowerQuery);
      final matchesMembers = group.members.any(
        (member) => member.name.toLowerCase().contains(lowerQuery),
      );
      return matchesName || matchesMembers;
    }).toList();
  }

  /// Filter activities by type and search query
  List<GroupActivityEntity> filterActivities(
    List<GroupActivityEntity> activities, {
    List<GroupActivityType>? types,
    String? searchQuery,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return activities.where((activity) {
      // Type filter
      if (types != null && types.isNotEmpty) {
        if (!types.contains(activity.type)) {
          return false;
        }
      }

      // Date range filter
      if (startDate != null && activity.timestamp.isBefore(startDate)) {
        return false;
      }
      if (endDate != null && activity.timestamp.isAfter(endDate)) {
        return false;
      }

      // Search query filter
      if (searchQuery != null && searchQuery.isNotEmpty) {
        final query = searchQuery.toLowerCase();
        final matchesDescription =
            activity.description.toLowerCase().contains(query);
        final matchesActor = activity.actorName.toLowerCase().contains(query);

        if (!matchesDescription && !matchesActor) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  /// Get quick filter presets for expenses
  static List<ExpenseFilter> getExpenseFilterPresets() {
    final now = DateTime.now();
    final thisWeek = now.subtract(const Duration(days: 7));
    final thisMonth = DateTime(now.year, now.month, 1);
    final lastMonth = DateTime(now.year, now.month - 1, 1);
    final lastMonthEnd = DateTime(now.year, now.month, 0);

    return [
      const ExpenseFilter(), // All expenses
      ExpenseFilter(startDate: thisWeek), // This week
      ExpenseFilter(startDate: thisMonth), // This month
      ExpenseFilter(startDate: lastMonth, endDate: lastMonthEnd), // Last month
      const ExpenseFilter(
          sortBy: SortBy.amount,
          sortOrder: SortOrder.descending), // Highest amount
    ];
  }

  /// Get quick filter presets for settlements
  static List<SettlementFilter> getSettlementFilterPresets() {
    return [
      const SettlementFilter(), // All settlements
      const SettlementFilter(statuses: [SettlementStatus.pending]), // Pending
      const SettlementFilter(
          statuses: [SettlementStatus.confirmed]), // Confirmed
      const SettlementFilter(
          statuses: [SettlementStatus.cancelled]), // Cancelled
      const SettlementFilter(
          sortBy: SortBy.amount,
          sortOrder: SortOrder.descending), // Highest amount
    ];
  }
}
