import 'package:flutter/material.dart';
import 'package:money_track/features/groups/domain/entities/shared_expense_entity.dart';

class SplitTypeSelector extends StatelessWidget {
  final EnhancedSplitType selectedType;
  final ValueChanged<EnhancedSplitType> onTypeChanged;

  const SplitTypeSelector({
    Key? key,
    required this.selectedType,
    required this.onTypeChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildSplitOption(
          context,
          type: EnhancedSplitType.equal,
          title: 'Equal Split',
          subtitle: 'Split equally among all participants',
          icon: Icons.pie_chart,
        ),
        const SizedBox(height: 8),
        _buildSplitOption(
          context,
          type: EnhancedSplitType.exact,
          title: 'Exact Amounts',
          subtitle: 'Enter exact amount for each person',
          icon: Icons.calculate,
        ),
        const SizedBox(height: 8),
        _buildSplitOption(
          context,
          type: EnhancedSplitType.percentage,
          title: 'Percentage',
          subtitle: 'Split by percentage for each person',
          icon: Icons.percent,
        ),
        const SizedBox(height: 8),
        _buildSplitOption(
          context,
          type: EnhancedSplitType.shares,
          title: 'Shares',
          subtitle: 'Split by shares (e.g., 2:1:1 ratio)',
          icon: Icons.share,
        ),
        const SizedBox(height: 8),
        _buildSplitOption(
          context,
          type: EnhancedSplitType.adjustment,
          title: 'Adjustment',
          subtitle: 'Manual adjustment of amounts',
          icon: Icons.tune,
        ),
      ],
    );
  }

  Widget _buildSplitOption(
    BuildContext context, {
    required EnhancedSplitType type,
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    final isSelected = selectedType == type;

    return Card(
      elevation: isSelected ? 4 : 1,
      color: isSelected
          ? Theme.of(context).primaryColor.withValues(alpha: 0.1)
          : null,
      child: ListTile(
        leading: Icon(
          icon,
          color: isSelected ? Theme.of(context).primaryColor : null,
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? Theme.of(context).primaryColor : null,
          ),
        ),
        subtitle: Text(subtitle),
        trailing: isSelected
            ? Icon(
                Icons.check_circle,
                color: Theme.of(context).primaryColor,
              )
            : null,
        onTap: () => onTypeChanged(type),
      ),
    );
  }
}

/// Helper extension for split type display
extension EnhancedSplitTypeExtension on EnhancedSplitType {
  String get displayName {
    switch (this) {
      case EnhancedSplitType.equal:
        return 'Equal Split';
      case EnhancedSplitType.exact:
        return 'Exact Amounts';
      case EnhancedSplitType.percentage:
        return 'Percentage';
      case EnhancedSplitType.shares:
        return 'Shares';
      case EnhancedSplitType.adjustment:
        return 'Adjustment';
    }
  }

  String get description {
    switch (this) {
      case EnhancedSplitType.equal:
        return 'Split equally among all participants';
      case EnhancedSplitType.exact:
        return 'Enter exact amount for each person';
      case EnhancedSplitType.percentage:
        return 'Split by percentage for each person';
      case EnhancedSplitType.shares:
        return 'Split by shares (e.g., 2:1:1 ratio)';
      case EnhancedSplitType.adjustment:
        return 'Manual adjustment of amounts';
    }
  }

  IconData get icon {
    switch (this) {
      case EnhancedSplitType.equal:
        return Icons.pie_chart;
      case EnhancedSplitType.exact:
        return Icons.calculate;
      case EnhancedSplitType.percentage:
        return Icons.percent;
      case EnhancedSplitType.shares:
        return Icons.share;
      case EnhancedSplitType.adjustment:
        return Icons.tune;
    }
  }
}
