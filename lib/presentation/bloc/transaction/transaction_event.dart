part of 'transaction_bloc.dart';

sealed class TransactionEvent extends Equatable {
  const TransactionEvent();

  @override
  List<Object> get props => [];
}

class GetAllTransaction extends TransactionEvent {}

class AddTransactionEvent extends TransactionEvent {
  final TransactionModel transactionModel;

  const AddTransactionEvent({required this.transactionModel});
}
