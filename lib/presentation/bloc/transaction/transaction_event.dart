part of 'transaction_bloc.dart';

sealed class TransactionEvent extends Equatable {
  const TransactionEvent();

  @override
  List<Object> get props => [];
}

class GetAllTransaction extends TransactionEvent {}

class AddTransactionEvent extends TransactionEvent {
  final String amount;
  final String description;
  final bool isExpense;
  final CategoryType categoryType;
  final CategoryModel categoryModel;
  const AddTransactionEvent({
    required this.amount,
    required this.description,
    required this.isExpense,
    required this.categoryType,
    required this.categoryModel,
  });
}
