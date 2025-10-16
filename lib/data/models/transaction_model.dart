import 'package:hive_ce/hive.dart';
import 'package:money_track/data/models/category_model.dart';
import 'package:money_track/domain/entities/transaction_entity.dart' as domain;
import 'package:money_track/domain/entities/category_entity.dart'
    as domain_category;

part 'transaction_model.g.dart';

@HiveType(typeId: 4)
class TransactionModel {
  @HiveField(0)
  final double amount;
  @HiveField(1)
  String? notes;
  @HiveField(2)
  final DateTime date;
  @HiveField(3)
  final CategoryType categoryType;
  @HiveField(4)
  final TransactionType transactionType;
  @HiveField(5)
  final CategoryModel categoryModel;
  @HiveField(6)
  final String id;
  @HiveField(7)
  final String? groupId;

  TransactionModel({
    required this.amount,
    required this.date,
    required this.categoryType,
    required this.transactionType,
    required this.categoryModel,
    required this.id,
    this.notes,
    this.groupId,
  });

  /// Convert from domain entity to data model
  factory TransactionModel.fromEntity(domain.TransactionEntity entity) {
    return TransactionModel(
      id: entity.id.isEmpty
          ? DateTime.now().microsecondsSinceEpoch.toString()
          : entity.id,
      amount: entity.amount,
      date: entity.date,
      categoryType: _mapDomainCategoryType(entity.categoryType),
      transactionType: _mapDomainTransactionType(entity.transactionType),
      categoryModel: CategoryModel.fromEntity(entity.category),
      notes: entity.notes,
      groupId: entity.groupId,
    );
  }

  /// Convert from data model to domain entity
  domain.TransactionEntity toEntity() {
    return domain.TransactionEntity(
      id: id,
      amount: amount,
      date: date,
      categoryType: _mapModelCategoryTypeToDomain(categoryType),
      transactionType: _mapModelTransactionTypeToDomain(transactionType),
      category: categoryModel.toEntity(),
      notes: notes,
      groupId: groupId,
    );
  }
}

// Helper functions to map between domain and model enums
CategoryType _mapDomainCategoryType(domain_category.CategoryType type) {
  return CategoryType.values[type.index];
}

TransactionType _mapDomainTransactionType(
    domain_category.TransactionType type) {
  return TransactionType.values[type.index];
}

domain_category.CategoryType _mapModelCategoryTypeToDomain(CategoryType type) {
  return domain_category.CategoryType.values[type.index];
}

domain_category.TransactionType _mapModelTransactionTypeToDomain(
    TransactionType type) {
  return domain_category.TransactionType.values[type.index];
}