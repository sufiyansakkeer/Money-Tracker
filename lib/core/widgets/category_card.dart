import 'package:flutter/material.dart';
import 'package:money_track/core/utils/sized_box_extension.dart';
import 'package:money_track/core/widgets/category_icon_widget.dart';
import 'package:money_track/domain/entities/category_entity.dart';

class CategoryCard extends StatelessWidget {
  const CategoryCard({
    super.key,
    required this.categoryType,
    required this.categoryName,
  });
  final CategoryType categoryType;
  final String categoryName;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CategoryIconWidget(categoryType: categoryType),
        10.height(),
        Text(
          categoryName,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
