import 'package:flutter/material.dart';
import 'package:money_track/core/constants/colors.dart';
import 'package:money_track/core/utils/currency_formatter.dart';
import 'package:money_track/core/utils/sized_box_extension.dart';
import 'package:money_track/core/utils/widget_extension.dart';
import 'package:money_track/domain/entities/category_entity.dart';
import 'package:money_track/core/widgets/category_icon_widget.dart';

class TransactionTile extends StatefulWidget {
  const TransactionTile({
    super.key,
    required this.categoryType,
    required this.categoryName,
    required this.time,
    required this.description,
    required this.amount,
    required this.type,
    this.onTap,
    this.onLongPress,
  });

  final CategoryType categoryType;
  final String categoryName;
  final String time;
  final String description;
  final double amount;
  final TransactionType type;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  @override
  State<TransactionTile> createState() => _TransactionTileState();
}

class _TransactionTileState extends State<TransactionTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onPressedChanged(bool isPressed) {
    if (isPressed) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
    setState(() {
      _isPressed = isPressed;
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = ColorConstants.getThemeColor(context);
    final transactionColor = widget.type == TransactionType.expense
        ? ColorConstants.getExpenseColor(context)
        : ColorConstants.getIncomeColor(context);

    return GestureDetector(
      onTap: widget.onTap,
      onLongPress: widget.onLongPress,
      onTapDown: (_) => _onPressedChanged(true),
      onTapUp: (_) => _onPressedChanged(false),
      onTapCancel: () => _onPressedChanged(false),
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          );
        },
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 6),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: themeColor.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
            border: Border.all(
              color: _isPressed
                  ? transactionColor.withValues(alpha: 0.3)
                  : Colors.grey.withValues(alpha: 0.1),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: transactionColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: CategoryIconWidget(
                  categoryType: widget.categoryType,
                  size: 28,
                  color: widget.categoryType.svgEnumModel.backgroundColor,
                ),
              ),
              16.width(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        widget.categoryName,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: ColorConstants.getTextColor(context),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        CurrencyFormatter.format(context, widget.amount,
                            showSign: true,
                            isExpense: widget.type == TransactionType.expense),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: transactionColor,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                  8.height(),
                  Row(
                    children: [
                      if (widget.description.isNotEmpty) ...[
                        Text(
                          widget.description,
                          style: TextStyle(
                            fontSize: 13,
                            color: ColorConstants.getTextColor(context)
                                .withValues(alpha: 0.6),
                            fontWeight: FontWeight.w400,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ).expand(),
                        8.width(),
                      ],
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.grey.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          widget.time,
                          style: TextStyle(
                            fontSize: 12,
                            color: ColorConstants.getTextColor(context)
                                .withValues(alpha: 0.7),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ).expand(),
            ],
          ),
        ),
      ),
    );
  }
}
