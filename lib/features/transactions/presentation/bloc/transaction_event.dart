part of 'transaction_bloc.dart';

abstract class TransactionEvent extends Equatable {
  const TransactionEvent();

  @override
  List<Object?> get props => [];
}

class GetAllTransactionsEvent extends TransactionEvent {}

class AddTransactionEvent extends TransactionEvent {
  final String amount;
  final DateTime date;
  final CategoryType categoryType;
  final bool isExpense;
  final CategoryEntity categoryModel;
  final String? description;

  const AddTransactionEvent({
    required this.amount,
    required this.date,
    required this.categoryType,
    required this.isExpense,
    required this.categoryModel,
    this.description,
  });

  @override
  List<Object?> get props => [
        amount,
        date,
        categoryType,
        isExpense,
        categoryModel,
        description,
      ];
}

class EditTransactionEvent extends TransactionEvent {
  final String id;
  final String amount;
  final DateTime date;
  final CategoryType categoryType;
  final bool isExpense;
  final CategoryEntity categoryModel;
  final String? description;

  const EditTransactionEvent({
    required this.id,
    required this.amount,
    required this.date,
    required this.categoryType,
    required this.isExpense,
    required this.categoryModel,
    this.description,
  });

  @override
  List<Object?> get props => [
        id,
        amount,
        date,
        categoryType,
        isExpense,
        categoryModel,
        description,
      ];
}

class DeleteTransactionEvent extends TransactionEvent {
  final String transactionId;

  const DeleteTransactionEvent({required this.transactionId});

  @override
  List<Object?> get props => [transactionId];
}
