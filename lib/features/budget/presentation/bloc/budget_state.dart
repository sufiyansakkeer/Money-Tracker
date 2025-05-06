part of 'budget_bloc.dart';

abstract class BudgetState extends Equatable {
  const BudgetState();
  
  @override
  List<Object?> get props => [];
}

class BudgetInitial extends BudgetState {
  const BudgetInitial();
}

class BudgetLoading extends BudgetState {
  const BudgetLoading();
}

class BudgetsLoaded extends BudgetState {
  final List<BudgetEntity> budgets;
  final List<TransactionEntity> transactions;

  const BudgetsLoaded({
    required this.budgets,
    required this.transactions,
  });

  @override
  List<Object?> get props => [budgets, transactions];

  BudgetsLoaded copyWith({
    List<BudgetEntity>? budgets,
    List<TransactionEntity>? transactions,
  }) {
    return BudgetsLoaded(
      budgets: budgets ?? this.budgets,
      transactions: transactions ?? this.transactions,
    );
  }
}

class BudgetError extends BudgetState {
  final String message;

  const BudgetError(this.message);

  @override
  List<Object?> get props => [message];
}

class BudgetAdded extends BudgetState {
  const BudgetAdded();
}

class BudgetUpdated extends BudgetState {
  const BudgetUpdated();
}

class BudgetDeleted extends BudgetState {
  const BudgetDeleted();
}
