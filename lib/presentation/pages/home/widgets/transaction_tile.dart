import 'package:flutter/material.dart';
import 'package:money_track/core/constants/colors.dart';
import 'package:money_track/helper/sized_box_extension.dart';
import 'package:money_track/helper/widget_extension.dart';
import 'package:money_track/models/categories_model/category_model.dart';
import 'package:money_track/presentation/widgets/category_icon_widget.dart';

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
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                // 10.width(),
                Text(
                  "₹$amount",
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
