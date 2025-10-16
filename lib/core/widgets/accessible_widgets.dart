import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';

/// Accessible button widget with proper semantic labels and focus management
class AccessibleButton extends StatelessWidget {
  const AccessibleButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.semanticLabel,
    this.tooltip,
    this.autofocus = false,
    this.focusNode,
  });

  final VoidCallback? onPressed;
  final Widget child;
  final String? semanticLabel;
  final String? tooltip;
  final bool autofocus;
  final FocusNode? focusNode;

  @override
  Widget build(BuildContext context) {
    Widget button = ElevatedButton(
      onPressed: onPressed,
      autofocus: autofocus,
      focusNode: focusNode,
      child: child,
    );

    if (tooltip != null) {
      button = Tooltip(
        message: tooltip!,
        child: button,
      );
    }

    return Semantics(
      label: semanticLabel,
      button: true,
      enabled: onPressed != null,
      child: button,
    );
  }
}

/// Accessible transaction tile with proper semantic information
class AccessibleTransactionTile extends StatelessWidget {
  const AccessibleTransactionTile({
    super.key,
    required this.title,
    required this.amount,
    required this.date,
    required this.category,
    required this.isIncome,
    this.onTap,
    this.onEdit,
    this.onDelete,
  });

  final String title;
  final double amount;
  final DateTime date;
  final String category;
  final bool isIncome;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final formattedAmount = amount.toStringAsFixed(2);
    final formattedDate = '${date.day}/${date.month}/${date.year}';
    final transactionType = isIncome ? 'Income' : 'Expense';

    // Create comprehensive semantic label
    final semanticLabel = '$transactionType transaction: $title, '
        'Amount: \$$formattedAmount, '
        'Category: $category, '
        'Date: $formattedDate';

    return Semantics(
      label: semanticLabel,
      button: onTap != null,
      child: Card(
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                // Transaction icon with semantic label
                Semantics(
                  label: '$transactionType icon',
                  child: Icon(
                    isIncome ? Icons.arrow_upward : Icons.arrow_downward,
                    color: isIncome ? Colors.green : Colors.red,
                    semanticLabel: transactionType,
                  ),
                ),

                const SizedBox(width: 16),

                // Transaction details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title with semantic label
                      Semantics(
                        label: 'Transaction title: $title',
                        child: Text(
                          title,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),

                      const SizedBox(height: 4),

                      // Category and date
                      Semantics(
                        label: 'Category: $category, Date: $formattedDate',
                        child: Text(
                          '$category • $formattedDate',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                    ],
                  ),
                ),

                // Amount with semantic label
                Semantics(
                  label: 'Amount: \$$formattedAmount',
                  child: Text(
                    '\$$formattedAmount',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: isIncome ? Colors.green : Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),

                // Action buttons with proper accessibility
                if (onEdit != null || onDelete != null) ...[
                  const SizedBox(width: 8),
                  _buildActionButtons(context),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return PopupMenuButton<String>(
      tooltip: 'Transaction options',
      icon: const Icon(Icons.more_vert),
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
        if (onEdit != null)
          const PopupMenuItem(
            value: 'edit',
            child: ListTile(
              leading: Icon(Icons.edit),
              title: Text('Edit'),
              contentPadding: EdgeInsets.zero,
            ),
          ),
        if (onDelete != null)
          const PopupMenuItem(
            value: 'delete',
            child: ListTile(
              leading: Icon(Icons.delete),
              title: Text('Delete'),
              contentPadding: EdgeInsets.zero,
            ),
          ),
      ],
    );
  }
}

/// Accessible form field with proper labels and error handling
class AccessibleFormField extends StatelessWidget {
  const AccessibleFormField({
    super.key,
    required this.label,
    this.hint,
    this.errorText,
    this.controller,
    this.onChanged,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.validator,
    this.autofocus = false,
    this.focusNode,
  });

  final String label;
  final String? hint;
  final String? errorText;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final TextInputType keyboardType;
  final bool obscureText;
  final String? Function(String?)? validator;
  final bool autofocus;
  final FocusNode? focusNode;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: label,
      textField: true,
      child: TextFormField(
        controller: controller,
        onChanged: onChanged,
        keyboardType: keyboardType,
        obscureText: obscureText,
        validator: validator,
        autofocus: autofocus,
        focusNode: focusNode,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          errorText: errorText,
          border: const OutlineInputBorder(),
          // Ensure proper contrast ratios
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
            borderSide: BorderSide(
              color: Theme.of(context).colorScheme.primary,
              width: 2,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Theme.of(context).colorScheme.error,
              width: 2,
            ),
          ),
        ),
      ),
    );
  }
}

/// Accessible amount display with proper formatting and semantics
class AccessibleAmountDisplay extends StatelessWidget {
  const AccessibleAmountDisplay({
    super.key,
    required this.amount,
    required this.label,
    this.isIncome = false,
    this.fontSize = 24,
  });

  final double amount;
  final String label;
  final bool isIncome;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final formattedAmount = amount.toStringAsFixed(2);
    final semanticLabel = '$label: \$$formattedAmount';

    return Semantics(
      label: semanticLabel,
      liveRegion: true, // Announces changes to screen readers
      child: Column(
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 4),
          Text(
            '\$$formattedAmount',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontSize: fontSize,
                  fontWeight: FontWeight.bold,
                  color: isIncome ? Colors.green : Colors.red,
                ),
          ),
        ],
      ),
    );
  }
}

/// Accessible navigation item with proper focus management
class AccessibleNavigationItem extends StatelessWidget {
  const AccessibleNavigationItem({
    super.key,
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.badge,
  });

  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final String? badge;

  @override
  Widget build(BuildContext context) {
    final semanticLabel = isSelected ? '$label, selected tab' : '$label tab';

    return Semantics(
      label: semanticLabel,
      button: true,
      selected: isSelected,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                children: [
                  Icon(
                    icon,
                    color: isSelected
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.onSurface.withAlpha(
                            ((Theme.of(context).colorScheme.onSurface.a * 255.0)
                                    .round() &
                                0xff)),
                  ),
                  if (badge != null)
                    Positioned(
                      right: -6,
                      top: -6,
                      child: Semantics(
                        label: '$badge notifications',
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.error,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 16,
                            minHeight: 16,
                          ),
                          child: Text(
                            badge!,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.onSurface.withAlpha(
                              ((Theme.of(context).colorScheme.onSurface.a *
                                          255.0)
                                      .round() &
                                  0xff)),
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Accessibility utilities
class AccessibilityUtils {
  /// Announce message to screen readers
  static void announceMessage(BuildContext context, String message) {
    SemanticsService.announce(message, TextDirection.ltr);
  }

  /// Check if high contrast is enabled
  static bool isHighContrastEnabled(BuildContext context) {
    return MediaQuery.of(context).highContrast;
  }

  /// Get accessible text scale factor
  static double getAccessibleTextScale(BuildContext context) {
    final textScaler = MediaQuery.of(context).textScaler;
    // Ensure minimum readable size
    return textScaler.scale(1.0).clamp(1.0, 2.0);
  }

  /// Create focus traversal order
  static List<FocusNode> createFocusTraversalOrder(List<FocusNode> nodes) {
    return nodes;
  }
}
