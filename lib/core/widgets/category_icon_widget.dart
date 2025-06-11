import 'package:flutter/material.dart';
import 'package:money_track/domain/entities/category_entity.dart';
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
            backgroundColor: const Color(0xFFFD3C4A));
      case CategoryType.salary:
        return SvgEnumModel(
            svgAsset: 'assets/svg/category/salary.svg',
            backgroundColor: const Color(0xFF00A86B));
      case CategoryType.shopping:
        return SvgEnumModel(
            svgAsset: 'assets/svg/category/shopping_bag.svg',
            backgroundColor: const Color(0xFFFF8A00));
      case CategoryType.transportation:
        return SvgEnumModel(
            svgAsset: 'assets/svg/category/car.svg',
            backgroundColor: const Color(0xFF246BFD));
      case CategoryType.subscription:
        return SvgEnumModel(
            svgAsset: 'assets/svg/category/recurring_bill.svg',
            backgroundColor: const Color(0xFF7F3DFF));
      default:
        return SvgEnumModel(
            svgAsset: 'assets/svg/category/Transaction.svg',
            backgroundColor: const Color(0xFF00C2CB));
    }
  }
}

class CategoryIconWidget extends StatelessWidget {
  const CategoryIconWidget({
    super.key,
    required this.categoryType,
    this.size = 30,
    this.color,
    this.padding = const EdgeInsets.all(16),
    this.borderRadius = 10,
  });

  final CategoryType categoryType;
  final double size;
  final Color? color;
  final EdgeInsetsGeometry padding;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final iconColor = color ?? categoryType.svgEnumModel.backgroundColor;

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        color: iconColor.withValues(alpha: 0.2),
      ),
      child: SizedBox(
        height: size,
        width: size,
        child: SvgPicture.asset(
          categoryType.svgEnumModel.svgAsset,
          colorFilter: categoryType == CategoryType.other
              ? null
              : ColorFilter.mode(iconColor, BlendMode.srcIn),
        ),
      ),
    );
  }
}
