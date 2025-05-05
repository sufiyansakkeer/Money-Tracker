import 'package:equatable/equatable.dart';
import 'package:money_track/domain/entities/category_entity.dart';

/// Entity class for transactions
class TransactionEntity extends Equatable {
  final String id;
  final double amount;
  final String? notes;
  final DateTime date;
  final CategoryType categoryType;
  final TransactionType transactionType;
  final CategoryEntity category;

  const TransactionEntity({
    required this.id,
    required this.amount,
    required this.date,
    required this.categoryType,
    required this.transactionType,
    required this.category,
    this.notes,
  });

  @override
  List<Object?> get props => [
        id,
        amount,
        notes,
        date,
        categoryType,
        transactionType,
        category,
      ];

  // Convert from domain entity to data model string representation
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'amount': amount,
      'notes': notes,
      'date': date.toIso8601String(),
      'categoryType': categoryType.index,
      'transactionType': transactionType.index,
      'category': category.toModelString(),
    };
  }

  // Create from data model map representation
  factory TransactionEntity.fromMap(Map<String, dynamic> map) {
    return TransactionEntity(
      id: map['id'],
      amount: map['amount'],
      notes: map['notes'],
      date: DateTime.parse(map['date']),
      categoryType: CategoryType.values[map['categoryType']],
      transactionType: TransactionType.values[map['transactionType']],
      category: CategoryEntity.fromModelString(map['category']),
    );
  }
}
