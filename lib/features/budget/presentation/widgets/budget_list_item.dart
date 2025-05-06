import 'package:flutter/material.dart';
import 'package:money_track/core/constants/colors.dart';
import 'package:money_track/domain/entities/category_entity.dart';
import 'package:money_track/domain/entities/transaction_entity.dart';
import 'package:money_track/features/budget/domain/entities/budget_entity.dart';
import 'package:money_track/features/budget/presentation/widgets/budget_progress_bar.dart';

class BudgetListItem extends StatelessWidget {
  final BudgetEntity budget;
  final List<TransactionEntity> transactions;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const BudgetListItem({
    super.key,
    required this.budget,
    required this.transactions,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onEdit,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    _getCategoryIcon(budget.category.categoryType),
                    color: ColorConstants.getThemeColor(context),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      budget.category.categoryName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit, size: 20),
                    onPressed: onEdit,
                    color: Colors.grey,
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, size: 20),
                    onPressed: onDelete,
                    color: Colors.grey,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              BudgetProgressBar(
                budget: budget,
                transactions: transactions,
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getCategoryIcon(categoryType) {
    switch (categoryType) {
      case CategoryType.salary:
        return Icons.attach_money;
      case CategoryType.shopping:
        return Icons.shopping_bag;
      case CategoryType.food:
        return Icons.restaurant;
      case CategoryType.transportation:
        return Icons.directions_car;
      case CategoryType.subscription:
        return Icons.subscriptions;
      case CategoryType.other:
      default:
        return Icons.category;
    }
  }
}
