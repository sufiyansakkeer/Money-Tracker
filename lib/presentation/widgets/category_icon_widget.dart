import 'package:flutter/material.dart';
import 'package:money_track/models/categories_model/category_model.dart';
import 'package:svg_flutter/svg_flutter.dart';

class SvgEnumModel {
  final String svgAsset;
  final Color backgroundColor;

  SvgEnumModel({
    required this.svgAsset,
    required this.backgroundColor,
  });
}

extension CategoryTypeExtension on CategoryType {
  SvgEnumModel get svgEnumModel {
    switch (this) {
      case CategoryType.food:
        return SvgEnumModel(
            svgAsset: 'assets/svg/category/restaurant.svg',
            backgroundColor: Colors.red);
      case CategoryType.salary:
        return SvgEnumModel(
            svgAsset: 'assets/svg/category/salary.svg',
            backgroundColor: const Color(0xFF00A86B));
      case CategoryType.shopping:
        return SvgEnumModel(
            svgAsset: 'assets/svg/category/shopping_bag.svg',
            backgroundColor: const Color(0xFFFCAC12));
      case CategoryType.transportation:
        return SvgEnumModel(
            svgAsset: 'assets/svg/category/car.svg',
            backgroundColor: const Color(0xFF2196F3));
      case CategoryType.subscription:
        return SvgEnumModel(
            svgAsset: 'assets/svg/category/recurring_bill.svg',
            backgroundColor: const Color(0xFF732EFF));
      default:
        return SvgEnumModel(
            svgAsset: 'assets/svg/category/Transaction.svg',
            backgroundColor: const Color(0xFFE728E7));
    }
  }
}

class CategoryIconWidget extends StatelessWidget {
  const CategoryIconWidget({super.key, required this.categoryType});
  final CategoryType categoryType;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(
        16,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(
          10,
        ),
        color: categoryType.svgEnumModel.backgroundColor.withValues(alpha: 0.4),
      ),
      child: SizedBox(
        height: 30,
        width: 30,
        child: SvgPicture.asset(
          categoryType.svgEnumModel.svgAsset,
          colorFilter: categoryType == CategoryType.other
              ? null
              : ColorFilter.mode(
                  categoryType.svgEnumModel.backgroundColor, BlendMode.srcIn),
        ),
      ),
    );
  }
}
