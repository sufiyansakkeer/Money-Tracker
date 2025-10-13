import 'package:hive_ce/hive.dart';
import 'package:money_track/data/models/category_model.dart';
import 'package:money_track/features/budget/domain/entities/budget_entity.dart'
    as domain;

part 'budget_model.g.dart';

@HiveType(typeId: 6)
class BudgetModel {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final double amount;

  @HiveField(3)
  final CategoryModel category;

  @HiveField(4)
  final BudgetPeriodType periodType;

  @HiveField(5)
  final DateTime startDate;

  @HiveField(6)
  final bool isActive;

  BudgetModel({
    required this.id,
    required this.name,
    required this.amount,
    required this.category,
    required this.periodType,
    required this.startDate,
    this.isActive = true,
  });

  /// Convert from domain entity to data model
  factory BudgetModel.fromEntity(domain.BudgetEntity entity) {
    return BudgetModel(
      id: entity.id,
      name: entity.name,
      amount: entity.amount,
      category: CategoryModel.fromEntity(entity.category),
      periodType: _mapDomainBudgetPeriodType(entity.periodType),
      startDate: entity.startDate,
      isActive: entity.isActive,
    );
  }

  /// Convert from data model to domain entity
  domain.BudgetEntity toEntity() {
    return domain.BudgetEntity(
      id: id,
      name: name,
      amount: amount,
      category: category.toEntity(),
      periodType: _mapModelBudgetPeriodTypeToDomain(periodType),
      startDate: startDate,
      isActive: isActive,
    );
  }
}

/// Map domain BudgetPeriodType to model BudgetPeriodType
BudgetPeriodType _mapDomainBudgetPeriodType(domain.BudgetPeriodType type) {
  return BudgetPeriodType.values[type.index];
}

/// Map model BudgetPeriodType to domain BudgetPeriodType
domain.BudgetPeriodType _mapModelBudgetPeriodTypeToDomain(
    BudgetPeriodType type) {
  return domain.BudgetPeriodType.values[type.index];
}

@HiveType(typeId: 7)
enum BudgetPeriodType {
  @HiveField(0)
  weekly,
  @HiveField(1)
  monthly,
}
