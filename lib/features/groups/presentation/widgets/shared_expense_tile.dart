import 'package:flutter/material.dart';
import 'package:money_track/features/groups/domain/entities/shared_expense_entity.dart';
import 'package:money_track/core/utils/expense_currency_formatter.dart';

import 'package:money_track/core/extensions/category_extensions.dart';
import 'package:money_track/features/groups/presentation/widgets/split_type_selector.dart';

class SharedExpenseTile extends StatelessWidget {
  final SharedExpenseEntity expense;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const SharedExpenseTile({
    Key? key,
    required this.expense,
    this.onTap,
    this.onEdit,
    this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              const SizedBox(height: 8),
              _buildDetails(context),
              const SizedBox(height: 12),
              _buildParticipants(context),
              if (expense.receiptUrls?.isNotEmpty == true) ...[
                const SizedBox(height: 8),
                _buildReceiptIndicator(context),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: expense.category.color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            expense.category.icon,
            color: expense.category.color,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                expense.title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (expense.description?.isNotEmpty == true)
                Text(
                  expense.description!,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              ExpenseCurrencyFormatter.format(
                  expense.totalAmount, expense.currency),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.green[700],
                  ),
            ),
            Text(
              DateFormatter.formatTime(expense.createdAt),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[500],
                  ),
            ),
          ],
        ),
        PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'edit':
                onEdit?.call();
                break;
              case 'delete':
                onDelete?.call();
                break;
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit, size: 18),
                  SizedBox(width: 8),
                  Text('Edit'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, size: 18, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Delete', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDetails(BuildContext context) {
    return Row(
      children: [
        _buildDetailChip(
          context,
          icon: Icons.people,
          label: '${expense.participants.length} people',
        ),
        const SizedBox(width: 8),
        _buildDetailChip(
          context,
          icon: expense.splitType.icon,
          label: expense.splitType.displayName,
        ),
        if (expense.isRecurring) ...[
          const SizedBox(width: 8),
          _buildDetailChip(
            context,
            icon: Icons.repeat,
            label: 'Recurring',
            color: Colors.blue,
          ),
        ],
        if (expense.isSettled) ...[
          const SizedBox(width: 8),
          _buildDetailChip(
            context,
            icon: Icons.check_circle,
            label: 'Settled',
            color: Colors.green,
          ),
        ],
      ],
    );
  }

  Widget _buildDetailChip(
    BuildContext context, {
    required IconData icon,
    required String label,
    Color? color,
  }) {
    final chipColor = color ?? Colors.grey[600];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: chipColor?.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: chipColor,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: chipColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildParticipants(BuildContext context) {
    final payers = expense.payers;
    final debtors = expense.debtors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (payers.isNotEmpty) ...[
          _buildParticipantRow(
            context,
            title: 'Paid by',
            participants: payers,
            showAmount: true,
            amountColor: Colors.green[700],
          ),
        ],
        if (debtors.isNotEmpty) ...[
          const SizedBox(height: 4),
          _buildParticipantRow(
            context,
            title: 'Split between',
            participants: debtors,
            showAmount: false,
          ),
        ],
      ],
    );
  }

  Widget _buildParticipantRow(
    BuildContext context, {
    required String title,
    required List<ExpenseParticipant> participants,
    required bool showAmount,
    Color? amountColor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
          ),
        ),
        Expanded(
          child: Wrap(
            spacing: 8,
            runSpacing: 4,
            children: participants.map((participant) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  showAmount
                      ? '${participant.memberName} (${ExpenseCurrencyFormatter.format(participant.paidAmount, expense.currency)})'
                      : participant.memberName,
                  style: TextStyle(
                    fontSize: 12,
                    color: showAmount ? amountColor : Colors.grey[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildReceiptIndicator(BuildContext context) {
    final receiptCount = expense.receiptUrls?.length ?? 0;

    return Row(
      children: [
        Icon(
          Icons.receipt,
          size: 16,
          color: Colors.grey[600],
        ),
        const SizedBox(width: 4),
        Text(
          '$receiptCount receipt${receiptCount == 1 ? '' : 's'}',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
        ),
      ],
    );
  }
}

/// Extension for date formatting
extension DateFormatter on DateTime {
  static String formatTime(DateTime dateTime) {
    final hour = dateTime.hour;
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);

    return '$displayHour:$minute $period';
  }
}
