import 'package:flutter/material.dart';
import 'package:money_track/features/groups/domain/entities/shared_expense_entity.dart';
import 'package:money_track/features/groups/presentation/widgets/shared_expense_tile.dart';

class SharedExpenseList extends StatelessWidget {
  final List<SharedExpenseEntity> expenses;
  final VoidCallback? onRefresh;
  final Function(SharedExpenseEntity)? onExpenseTap;
  final Function(SharedExpenseEntity)? onExpenseEdit;
  final Function(SharedExpenseEntity)? onExpenseDelete;
  final bool isLoading;
  final String? emptyMessage;

  const SharedExpenseList({
    Key? key,
    required this.expenses,
    this.onRefresh,
    this.onExpenseTap,
    this.onExpenseEdit,
    this.onExpenseDelete,
    this.isLoading = false,
    this.emptyMessage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (expenses.isEmpty) {
      return _buildEmptyState(context);
    }

    return RefreshIndicator(
      onRefresh: () async {
        onRefresh?.call();
      },
      child: _buildExpenseList(),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            emptyMessage ?? 'No shared expenses yet',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add your first shared expense to get started',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[500],
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildExpenseList() {
    // Group expenses by date
    final groupedExpenses = _groupExpensesByDate(expenses);

    return ListView.builder(
      itemCount: groupedExpenses.length,
      itemBuilder: (context, index) {
        final dateGroup = groupedExpenses[index];
        return _buildDateGroup(dateGroup);
      },
    );
  }

  Widget _buildDateGroup(DateGroup dateGroup) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDateHeader(dateGroup.date, dateGroup.totalAmount),
        ...dateGroup.expenses.map((expense) => SharedExpenseTile(
              expense: expense,
              onTap: () => onExpenseTap?.call(expense),
              onEdit: () => onExpenseEdit?.call(expense),
              onDelete: () => onExpenseDelete?.call(expense),
            )),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildDateHeader(DateTime date, double totalAmount) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.grey[100],
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            DateFormatter.formatDateHeader(date),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          Text(
            'Total: \$${totalAmount.toStringAsFixed(2)}',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: Colors.green,
            ),
          ),
        ],
      ),
    );
  }

  List<DateGroup> _groupExpensesByDate(List<SharedExpenseEntity> expenses) {
    final Map<String, List<SharedExpenseEntity>> grouped = {};

    for (final expense in expenses) {
      final dateKey = DateFormatter.formatDateKey(expense.createdAt);
      grouped.putIfAbsent(dateKey, () => []).add(expense);
    }

    final dateGroups = grouped.entries.map((entry) {
      final date = DateTime.parse(entry.key);
      final expenseList = entry.value;
      final totalAmount =
          expenseList.fold(0.0, (sum, expense) => sum + expense.totalAmount);

      return DateGroup(
        date: date,
        expenses: expenseList,
        totalAmount: totalAmount,
      );
    }).toList();

    // Sort by date (newest first)
    dateGroups.sort((a, b) => b.date.compareTo(a.date));

    return dateGroups;
  }
}

class DateGroup {
  final DateTime date;
  final List<SharedExpenseEntity> expenses;
  final double totalAmount;

  DateGroup({
    required this.date,
    required this.expenses,
    required this.totalAmount,
  });
}

/// Utility class for date formatting
class DateFormatter {
  static String formatDateHeader(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final expenseDate = DateTime(date.year, date.month, date.day);

    if (expenseDate == today) {
      return 'Today';
    } else if (expenseDate == yesterday) {
      return 'Yesterday';
    } else if (now.difference(expenseDate).inDays < 7) {
      return _formatWeekday(expenseDate);
    } else {
      return _formatDate(expenseDate);
    }
  }

  static String formatDateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  static String _formatWeekday(DateTime date) {
    const weekdays = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday'
    ];
    return weekdays[date.weekday - 1];
  }

  static String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}
