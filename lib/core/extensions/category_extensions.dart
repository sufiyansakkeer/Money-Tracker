import 'package:flutter/material.dart';
import 'package:money_track/domain/entities/category_entity.dart';

/// Extension to provide icon and color properties for CategoryEntity
extension CategoryEntityExtensions on CategoryEntity {
  /// Get the icon for this category
  IconData get icon {
    switch (categoryType) {
      case CategoryType.food:
        return Icons.restaurant;
      case CategoryType.salary:
        return Icons.attach_money;
      case CategoryType.shopping:
        return Icons.shopping_bag;
      case CategoryType.transportation:
        return Icons.directions_car;
      case CategoryType.subscription:
        return Icons.subscriptions;
      case CategoryType.other:
        // default:
        return Icons.category;
    }
  }

  /// Get the color for this category
  Color get color {
    switch (categoryType) {
      case CategoryType.food:
        return const Color(0xFFFD3C4A);
      case CategoryType.salary:
        return const Color(0xFF00A86B);
      case CategoryType.shopping:
        return const Color(0xFFFF8A00);
      case CategoryType.transportation:
        return const Color(0xFF246BFD);
      case CategoryType.subscription:
        return const Color(0xFF7F3DFF);
      case CategoryType.other:
        // default:
        return const Color(0xFF00C2CB);
    }
  }

  /// Get a default category for expenses
  static CategoryEntity get defaultExpenseCategory {
    return const CategoryEntity(
      id: 'default-expense',
      categoryName: 'General Expense',
      categoryType: CategoryType.other,
      type: TransactionType.expense,
    );
  }

  /// Create a category entity from category type
  static CategoryEntity fromCategoryType(
    CategoryType categoryType, {
    String? id,
    String? name,
    TransactionType type = TransactionType.expense,
  }) {
    final categoryName = name ?? _getCategoryName(categoryType);
    return CategoryEntity(
      id: id ?? 'category-${categoryType.name}',
      categoryName: categoryName,
      categoryType: categoryType,
      type: type,
    );
  }

  static String _getCategoryName(CategoryType categoryType) {
    switch (categoryType) {
      case CategoryType.food:
        return 'Food & Dining';
      case CategoryType.salary:
        return 'Salary';
      case CategoryType.shopping:
        return 'Shopping';
      case CategoryType.transportation:
        return 'Transportation';
      case CategoryType.subscription:
        return 'Subscriptions';
      case CategoryType.other:
        // default:
        return 'Other';
    }
  }
}
