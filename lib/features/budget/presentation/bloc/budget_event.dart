part of 'budget_bloc.dart';

abstract class BudgetEvent extends Equatable {
  const BudgetEvent();

  @override
  List<Object?> get props => [];
}

class LoadBudgets extends BudgetEvent {
  const LoadBudgets();
}

class AddBudget extends BudgetEvent {
  final BudgetEntity budget;

  const AddBudget(this.budget);

  @override
  List<Object?> get props => [budget];
}

class UpdateBudget extends BudgetEvent {
  final BudgetEntity budget;

  const UpdateBudget(this.budget);

  @override
  List<Object?> get props => [budget];
}

class DeleteBudget extends BudgetEvent {
  final String budgetId;

  const DeleteBudget(this.budgetId);

  @override
  List<Object?> get props => [budgetId];
}

class LoadBudgetsByCategory extends BudgetEvent {
  final String categoryId;

  const LoadBudgetsByCategory(this.categoryId);

  @override
  List<Object?> get props => [categoryId];
}

class LoadActiveBudgets extends BudgetEvent {
  const LoadActiveBudgets();
}

class CheckBudgetNotifications extends BudgetEvent {
  final List<TransactionEntity> transactions;

  const CheckBudgetNotifications(this.transactions);

  @override
  List<Object?> get props => [transactions];
}
