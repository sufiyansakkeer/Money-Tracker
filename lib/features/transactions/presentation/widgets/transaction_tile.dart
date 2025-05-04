import 'package:flutter/material.dart';
import 'package:money_track/core/constants/colors.dart';
import 'package:money_track/core/utils/currency_formatter.dart';
import 'package:money_track/core/utils/sized_box_extension.dart';
import 'package:money_track/core/utils/widget_extension.dart';
import 'package:money_track/domain/entities/category_entity.dart';
import 'package:money_track/core/widgets/category_icon_widget.dart';

class TransactionTile extends StatelessWidget {
  const TransactionTile({
    super.key,
    required this.categoryType,
    required this.categoryName,
    required this.time,
    required this.description,
    required this.amount,
    required this.type,
  });
  final CategoryType categoryType;
  final String categoryName;
  final String time;
  final String description;
  final double amount;
  final TransactionType type;
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CategoryIconWidget(
          categoryType: categoryType,
        ),
        10.width(),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  categoryName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  CurrencyFormatter.format(context, amount,
                      showSign: true,
                      isExpense: type == TransactionType.expense),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: type == TransactionType.expense
                        ? ColorConstants.expenseColor
                        : ColorConstants.incomeColor,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
            10.height(),
            Row(
              children: [
                Text(
                  description,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.w400,
                  ),
                  overflow: TextOverflow.ellipsis,
                ).expand(),
                10.width(),
                Text(
                  time,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ).expand(),
      ],
    );
  }
}
