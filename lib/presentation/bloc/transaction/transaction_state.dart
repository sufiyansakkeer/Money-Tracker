part of 'transaction_bloc.dart';

sealed class TransactionState extends Equatable {
  const TransactionState();

  @override
  List<Object> get props => [];
}

final class TransactionInitial extends TransactionState {}

final class TransactionLoading extends TransactionState {}

final class TransactionLoaded extends TransactionState {
  final List<TransactionModel> transactionList;

  const TransactionLoaded({required this.transactionList});
  @override
  List<Object> get props => [transactionList];
}

final class TransactionError extends TransactionState {}
