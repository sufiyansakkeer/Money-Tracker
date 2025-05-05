part of 'total_transaction_cubit.dart';

abstract class TotalTransactionState extends Equatable {
  const TotalTransactionState();
  
  @override
  List<Object> get props => [];
}

class TotalTransactionInitial extends TotalTransactionState {}

class TotalTransactionSuccess extends TotalTransactionState {
  final double totalIncome;
  final double totalExpense;

  const TotalTransactionSuccess({
    required this.totalIncome,
    required this.totalExpense,
  });

  @override
  List<Object> get props => [
        totalExpense,
        totalIncome,
      ];
}
