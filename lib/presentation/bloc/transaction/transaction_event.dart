part of 'transaction_bloc.dart';

sealed class TransactionEvent extends Equatable {
  const TransactionEvent();

  @override
  List<Object> get props => [];
}

class GetAllTransaction extends TransactionEvent {}

class FilterTransaction extends TransactionEvent {
  final FilterData filterData;

  const FilterTransaction({required this.filterData});
}

class DeleteTransactionEvent extends TransactionEvent {
  final TransactionModel transactionModel;

  const DeleteTransactionEvent({required this.transactionModel});
}

class AddTransactionEvent extends TransactionEvent {
  final String amount;
  final String description;
  final bool isExpense;
  final CategoryType categoryType;
  final CategoryModel categoryModel;
  final DateTime date;
  const AddTransactionEvent({
    required this.amount,
    required this.date,
    required this.description,
    required this.isExpense,
    required this.categoryType,
    required this.categoryModel,
  });
}

class EditTransactionEvent extends TransactionEvent {
  final String id;
  final String amount;
  final String description;
  final bool isExpense;
  final CategoryType categoryType;
  final CategoryModel categoryModel;
  final DateTime date;
  const EditTransactionEvent({
    required this.id,
    required this.amount,
    required this.date,
    required this.description,
    required this.isExpense,
    required this.categoryType,
    required this.categoryModel,
  });
}
