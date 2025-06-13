import 'package:flutter/material.dart';
import 'package:money_track/core/utils/currency_formatter.dart';
import 'package:money_track/domain/entities/transaction_entity.dart';
import 'package:money_track/features/budget/domain/entities/budget_entity.dart';
import 'package:money_track/features/budget/domain/utils/budget_progress_calculator.dart';

class BudgetProgressBar extends StatelessWidget {
  final BudgetEntity budget;
  final List<TransactionEntity> transactions;

  const BudgetProgressBar({
    super.key,
    required this.budget,
    required this.transactions,
  });

  @override
  Widget build(BuildContext context) {
    final double percentage =
        BudgetProgressCalculator.calculateBudgetUsedPercentage(
      budget,
      transactions,
    );

    final double spent = BudgetProgressCalculator.calculateSpentAmount(
      budget,
      transactions,
    );

    final double remaining = BudgetProgressCalculator.calculateRemainingAmount(
      budget,
      transactions,
    );

    // Determine color based on percentage
    Color progressColor;
    if (percentage < 0.7) {
      progressColor = Colors.green;
    } else if (percentage < 0.9) {
      progressColor = Colors.orange;
    } else {
      progressColor = Colors.red;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              budget.name,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            Text(
              '${(percentage * 100).toStringAsFixed(1)}%',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: progressColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: percentage,
            backgroundColor: Colors.grey[300],
            color: progressColor,
            minHeight: 10,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Spent: ${CurrencyFormatter.format(context, spent)}',
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 12,
              ),
            ),
            Text(
              'Remaining: ${CurrencyFormatter.format(context, remaining)}',
              style: TextStyle(
                color: progressColor,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'Budget: ${CurrencyFormatter.format(context, budget.amount)} · ${budget.periodType.name.toUpperCase()}',
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
