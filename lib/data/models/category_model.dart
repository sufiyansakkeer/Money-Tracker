import 'package:hive_ce/hive.dart';
import 'package:money_track/domain/entities/category_entity.dart' as domain;

part 'category_model.g.dart';

@HiveType(typeId: 1)
class CategoryModel {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String categoryName;
  @HiveField(2)
  final CategoryType categoryType;
  @HiveField(3)
  final TransactionType type;
  @HiveField(4)
  final bool isDeleted;

  CategoryModel({
    required this.id,
    required this.categoryName,
    required this.type,
    this.categoryType = CategoryType.other,
    this.isDeleted = false,
  });

  /// Convert from domain entity to data model
  factory CategoryModel.fromEntity(domain.CategoryEntity entity) {
    return CategoryModel(
      id: entity.id,
      categoryName: entity.categoryName,
      type: _mapDomainTransactionType(entity.type),
      categoryType: _mapDomainCategoryType(entity.categoryType),
      isDeleted: entity.isDeleted,
    );
  }

  /// Convert from data model to domain entity
  domain.CategoryEntity toEntity() {
    return domain.CategoryEntity(
      id: id,
      categoryName: categoryName,
      type: _mapModelTransactionTypeToDomain(type),
      categoryType: _mapModelCategoryTypeToDomain(categoryType),
      isDeleted: isDeleted,
    );
  }
}

// Helper functions to map between domain and model enums
CategoryType _mapDomainCategoryType(domain.CategoryType type) {
  return CategoryType.values[type.index];
}

TransactionType _mapDomainTransactionType(domain.TransactionType type) {
  return TransactionType.values[type.index];
}

domain.CategoryType _mapModelCategoryTypeToDomain(CategoryType type) {
  return domain.CategoryType.values[type.index];
}

domain.TransactionType _mapModelTransactionTypeToDomain(TransactionType type) {
  return domain.TransactionType.values[type.index];
}

@HiveType(typeId: 2)
enum TransactionType {
  @HiveField(0)
  income,
  @HiveField(1)
  expense,
}

@HiveType(typeId: 3)
enum CategoryType {
  @HiveField(0)
  salary,
  @HiveField(1)
  shopping,
  @HiveField(2)
  food,
  @HiveField(3)
  transportation,
  @HiveField(4)
  subscription,
  @HiveField(5)
  other,
}
