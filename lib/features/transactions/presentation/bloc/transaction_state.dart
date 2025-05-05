part of 'transaction_bloc.dart';

abstract class TransactionState extends Equatable {
  const TransactionState();
  
  @override
  List<Object?> get props => [];
}

class TransactionInitial extends TransactionState {}

class TransactionLoading extends TransactionState {}

class TransactionLoaded extends TransactionState {
  final List<TransactionEntity> transactionList;

  const TransactionLoaded({required this.transactionList});

  @override
  List<Object?> get props => [transactionList];
}

class TransactionError extends TransactionState {
  final String message;

  const TransactionError({required this.message});

  @override
  List<Object?> get props => [message];
}
