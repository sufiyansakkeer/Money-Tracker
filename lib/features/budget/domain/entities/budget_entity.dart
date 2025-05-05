import 'package:equatable/equatable.dart';
import 'package:money_track/domain/entities/category_entity.dart';

/// Enum for budget period types
enum BudgetPeriodType {
  weekly,
  monthly,
}

/// Entity class for budgets
class BudgetEntity extends Equatable {
  final String id;
  final String name;
  final double amount;
  final CategoryEntity category;
  final BudgetPeriodType periodType;
  final DateTime startDate;
  final bool isActive;

  const BudgetEntity({
    required this.id,
    required this.name,
    required this.amount,
    required this.category,
    required this.periodType,
    required this.startDate,
    this.isActive = true,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        amount,
        category,
        periodType,
        startDate,
        isActive,
      ];

  // Convert from domain entity to data model map representation
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'amount': amount,
      'category': category.toModelString(),
      'periodType': periodType.index,
      'startDate': startDate.toIso8601String(),
      'isActive': isActive,
    };
  }

  // Create from data model map representation
  factory BudgetEntity.fromMap(Map<String, dynamic> map) {
    return BudgetEntity(
      id: map['id'],
      name: map['name'],
      amount: map['amount'],
      category: CategoryEntity.fromModelString(map['category']),
      periodType: BudgetPeriodType.values[map['periodType']],
      startDate: DateTime.parse(map['startDate']),
      isActive: map['isActive'],
    );
  }
}
