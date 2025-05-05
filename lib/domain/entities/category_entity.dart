import 'package:equatable/equatable.dart';

/// Enum for transaction types
enum TransactionType {
  income,
  expense,
}

/// Enum for category types
enum CategoryType {
  salary,
  shopping,
  food,
  transportation,
  subscription,
  other,
}

/// Entity class for categories
class CategoryEntity extends Equatable {
  final String id;
  final String categoryName;
  final CategoryType categoryType;
  final TransactionType type;
  final bool isDeleted;

  const CategoryEntity({
    required this.id,
    required this.categoryName,
    required this.type,
    this.categoryType = CategoryType.other,
    this.isDeleted = false,
  });

  @override
  List<Object?> get props => [
        id,
        categoryName,
        categoryType,
        type,
        isDeleted,
      ];

  // Convert from domain entity to data model string representation
  String toModelString() {
    return '$id|$categoryName|${categoryType.index}|${type.index}|$isDeleted';
  }

  // Create from data model string representation
  factory CategoryEntity.fromModelString(String modelString) {
    final parts = modelString.split('|');
    return CategoryEntity(
      id: parts[0],
      categoryName: parts[1],
      categoryType: CategoryType.values[int.parse(parts[2])],
      type: TransactionType.values[int.parse(parts[3])],
      isDeleted: parts[4] == 'true',
    );
  }
}
