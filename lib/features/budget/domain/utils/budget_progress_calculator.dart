import 'dart:developer';
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
    log('Calculating spent amount for budget: ${budget.name}, category: ${budget.category.categoryName}, total transactions: ${transactions.length}');

    // Filter transactions by category and date range
    final filteredTransactions = transactions.where((transaction) {
      // Only include expense transactions
      if (transaction.transactionType != TransactionType.expense) {
        log('Skipping transaction ${transaction.id}: Not an expense');
        return false;
      }

      // Match by category
      if (transaction.category.id != budget.category.id) {
        log('Skipping transaction ${transaction.id}: Category mismatch - transaction category: ${transaction.category.id}, budget category: ${budget.category.id}');
        return false;
      }

      // Check if transaction is within the budget period
      final bool inPeriod = isTransactionInBudgetPeriod(transaction, budget);
      if (!inPeriod) {
        log('Skipping transaction ${transaction.id}: Not in budget period - transaction date: ${transaction.date}');
      } else {
        log('Including transaction ${transaction.id}: Amount ${transaction.amount}, Date: ${transaction.date}');
      }
      return inPeriod;
    }).toList();

    log('Filtered transactions count: ${filteredTransactions.length}');

    // Sum up the amounts
    final double total = filteredTransactions.fold(
      0.0,
      (sum, transaction) => sum + transaction.amount,
    );

    log('Total spent amount: $total');
    return total;
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

    log('Checking if transaction date ${transaction.date} is in budget period: $periodStart to $periodEnd');

    // Create date-only versions for comparison (no time component)
    final DateTime transactionDate = DateTime(
      transaction.date.year,
      transaction.date.month,
      transaction.date.day,
    );

    final DateTime periodStartDate = DateTime(
      periodStart.year,
      periodStart.month,
      periodStart.day,
    );

    final DateTime periodEndDate = DateTime(
      periodEnd.year,
      periodEnd.month,
      periodEnd.day,
    );

    // Include transactions on the start and end dates
    final bool isInPeriod =
        (transactionDate.isAtSameMomentAs(periodStartDate) ||
                transactionDate.isAfter(periodStartDate)) &&
            (transactionDate.isAtSameMomentAs(periodEndDate) ||
                transactionDate.isBefore(periodEndDate));

    log('Transaction ${transaction.id} is ${isInPeriod ? "in" : "not in"} budget period');
    return isInPeriod;
  }

  /// Get the start date of the current budget period
  static DateTime _getPeriodStartDate(BudgetEntity budget) {
    final DateTime now = DateTime.now();
    final DateTime startDate = budget.startDate;

    log('Calculating period start date for budget: ${budget.name}, type: ${budget.periodType}, start date: $startDate, current date: $now');

    DateTime result;
    if (budget.periodType == BudgetPeriodType.monthly) {
      // If it's a monthly budget, get the start of the current month
      if (now.isBefore(startDate)) {
        log('Current date is before budget start date, using budget start date');
        result = startDate;
      } else {
        // Calculate months passed since start date
        int monthsPassed =
            (now.year - startDate.year) * 12 + now.month - startDate.month;

        log('Months passed since budget start: $monthsPassed');

        // Get the start date for the current period
        result = DateTime(
          startDate.year + (monthsPassed ~/ 12),
          startDate.month + (monthsPassed % 12),
          startDate.day,
        );
      }
    } else {
      // If it's a weekly budget, get the start of the current week
      if (now.isBefore(startDate)) {
        log('Current date is before budget start date, using budget start date');
        result = startDate;
      } else {
        // Calculate days passed since start date
        int daysPassed = now.difference(startDate).inDays;
        int weeksPassed = daysPassed ~/ 7;

        log('Days passed since budget start: $daysPassed, weeks passed: $weeksPassed');

        // Get the start date for the current period
        result = startDate.add(Duration(days: weeksPassed * 7));
      }
    }

    log('Calculated period start date: $result');
    return result;
  }

  /// Get the end date of the current budget period
  static DateTime _getPeriodEndDate(BudgetEntity budget) {
    final DateTime periodStart = _getPeriodStartDate(budget);

    log('Calculating period end date for budget: ${budget.name}, period type: ${budget.periodType}, period start: $periodStart');

    DateTime result;
    if (budget.periodType == BudgetPeriodType.monthly) {
      // For monthly budget, end date is the last day of the month
      final nextMonth = periodStart.month < 12
          ? DateTime(periodStart.year, periodStart.month + 1, 1)
          : DateTime(periodStart.year + 1, 1, 1);

      result = nextMonth.subtract(const Duration(days: 1));
      log('Monthly budget: next month start: $nextMonth, end date (last day of month): $result');
    } else {
      // For weekly budget, end date is 6 days after the start date
      result = periodStart.add(const Duration(days: 6));
      log('Weekly budget: end date (start + 6 days): $result');
    }

    return result;
  }
}
