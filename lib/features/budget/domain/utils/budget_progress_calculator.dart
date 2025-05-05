import 'package:money_track/domain/entities/category_entity.dart';
import 'package:money_track/domain/entities/transaction_entity.dart';
import 'package:money_track/features/budget/domain/entities/budget_entity.dart';

/// Utility class for calculating budget progress
class BudgetProgressCalculator {
  /// Calculate the percentage of budget used
  static double calculateBudgetUsedPercentage(
    BudgetEntity budget,
    List<TransactionEntity> transactions,
  ) {
    final double spent = calculateSpentAmount(budget, transactions);
    return (spent / budget.amount).clamp(0.0, 1.0);
  }

  /// Calculate the amount spent for a budget
  static double calculateSpentAmount(
    BudgetEntity budget,
    List<TransactionEntity> transactions,
  ) {
    // Filter transactions by category and date range
    final filteredTransactions = transactions.where((transaction) {
      // Only include expense transactions
      if (transaction.transactionType != TransactionType.expense) {
        return false;
      }

      // Match by category
      if (transaction.category.id != budget.category.id) {
        return false;
      }

      // Check if transaction is within the budget period
      return isTransactionInBudgetPeriod(transaction, budget);
    });

    // Sum up the amounts
    return filteredTransactions.fold(
      0.0,
      (sum, transaction) => sum + transaction.amount,
    );
  }

  /// Calculate the remaining amount for a budget
  static double calculateRemainingAmount(
    BudgetEntity budget,
    List<TransactionEntity> transactions,
  ) {
    final double spent = calculateSpentAmount(budget, transactions);
    return (budget.amount - spent).clamp(0.0, double.infinity);
  }

  /// Check if a transaction is within the budget period
  static bool isTransactionInBudgetPeriod(
    TransactionEntity transaction,
    BudgetEntity budget,
  ) {
    final DateTime periodStart = _getPeriodStartDate(budget);
    final DateTime periodEnd = _getPeriodEndDate(budget);

    return transaction.date.isAfter(periodStart) &&
        transaction.date.isBefore(periodEnd.add(const Duration(days: 1)));
  }

  /// Get the start date of the current budget period
  static DateTime _getPeriodStartDate(BudgetEntity budget) {
    final DateTime now = DateTime.now();
    final DateTime startDate = budget.startDate;

    if (budget.periodType == BudgetPeriodType.monthly) {
      // If it's a monthly budget, get the start of the current month
      if (now.isBefore(startDate)) {
        return startDate;
      }

      // Calculate months passed since start date
      int monthsPassed =
          (now.year - startDate.year) * 12 + now.month - startDate.month;

      // Get the start date for the current period
      return DateTime(
        startDate.year + (monthsPassed ~/ 12),
        startDate.month + (monthsPassed % 12),
        startDate.day,
      );
    } else {
      // If it's a weekly budget, get the start of the current week
      if (now.isBefore(startDate)) {
        return startDate;
      }

      // Calculate days passed since start date
      int daysPassed = now.difference(startDate).inDays;
      int weeksPassed = daysPassed ~/ 7;

      // Get the start date for the current period
      return startDate.add(Duration(days: weeksPassed * 7));
    }
  }

  /// Get the end date of the current budget period
  static DateTime _getPeriodEndDate(BudgetEntity budget) {
    final DateTime periodStart = _getPeriodStartDate(budget);

    if (budget.periodType == BudgetPeriodType.monthly) {
      // For monthly budget, end date is the last day of the month
      final nextMonth = periodStart.month < 12
          ? DateTime(periodStart.year, periodStart.month + 1, 1)
          : DateTime(periodStart.year + 1, 1, 1);

      return nextMonth.subtract(const Duration(days: 1));
    } else {
      // For weekly budget, end date is 6 days after the start date
      return periodStart.add(const Duration(days: 6));
    }
  }
}
