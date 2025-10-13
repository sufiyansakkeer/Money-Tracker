import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:money_track/core/error/result.dart';
import 'package:money_track/domain/entities/transaction_entity.dart';
import 'package:money_track/domain/usecases/transaction/get_all_transactions_usecase.dart';
import 'package:money_track/features/budget/domain/entities/budget_entity.dart';
import 'package:money_track/features/budget/domain/usecases/add_budget_usecase.dart';
import 'package:money_track/features/budget/domain/usecases/delete_budget_usecase.dart';
import 'package:money_track/features/budget/domain/usecases/edit_budget_usecase.dart';
import 'package:money_track/features/budget/domain/usecases/get_active_budgets_usecase.dart';
import 'package:money_track/features/budget/domain/usecases/get_all_budgets_usecase.dart';
import 'package:money_track/features/budget/domain/usecases/get_budgets_by_category_usecase.dart';

part 'budget_event.dart';
part 'budget_state.dart';

class BudgetBloc extends Bloc<BudgetEvent, BudgetState> {
  final GetAllBudgetsUseCase getAllBudgetsUseCase;
  final AddBudgetUseCase addBudgetUseCase;
  final EditBudgetUseCase editBudgetUseCase;
  final DeleteBudgetUseCase deleteBudgetUseCase;
  final GetBudgetsByCategoryUseCase getBudgetsByCategoryUseCase;
  final GetActiveBudgetsUseCase getActiveBudgetsUseCase;
  final GetAllTransactionsUseCase getAllTransactionsUseCase;

  BudgetBloc({
    required this.getAllBudgetsUseCase,
    required this.addBudgetUseCase,
    required this.editBudgetUseCase,
    required this.deleteBudgetUseCase,
    required this.getBudgetsByCategoryUseCase,
    required this.getActiveBudgetsUseCase,
    required this.getAllTransactionsUseCase,
  }) : super(const BudgetInitial()) {
    on<LoadBudgets>(_onLoadBudgets);
    on<AddBudget>(_onAddBudget);
    on<UpdateBudget>(_onUpdateBudget);
    on<DeleteBudget>(_onDeleteBudget);
    on<LoadBudgetsByCategory>(_onLoadBudgetsByCategory);
    on<LoadActiveBudgets>(_onLoadActiveBudgets);
    on<CheckBudgetNotifications>(_onCheckBudgetNotifications);
    on<RefreshBudgetsOnTransactionChange>(_onRefreshBudgetsOnTransactionChange);
  }

  Future<void> _onLoadBudgets(
    LoadBudgets event,
    Emitter<BudgetState> emit,
  ) async {
    emit(const BudgetLoading());

    // Get all budgets
    final budgetsResult = await getAllBudgetsUseCase();

    if (budgetsResult is Error<List<BudgetEntity>>) {
      emit(BudgetError((budgetsResult).failure.message));
      return;
    }

    final budgets = (budgetsResult as Success<List<BudgetEntity>>).data;

    // Get all transactions for budget progress calculation
    final transactionsResult = await getAllTransactionsUseCase();

    if (transactionsResult is Error<List<TransactionEntity>>) {
      emit(BudgetError((transactionsResult).failure.message));
      return;
    }

    final transactions =
        (transactionsResult as Success<List<TransactionEntity>>).data;

    emit(BudgetsLoaded(
      budgets: budgets,
      transactions: transactions,
    ));
  }

  Future<void> _onAddBudget(
    AddBudget event,
    Emitter<BudgetState> emit,
  ) async {
    emit(const BudgetLoading());

    final result = await addBudgetUseCase(params: event.budget);

    if (result is Error<String>) {
      emit(BudgetError((result).failure.message));
      return;
    }

    emit(const BudgetAdded());

    // Reload budgets after adding
    add(const LoadBudgets());
  }

  Future<void> _onUpdateBudget(
    UpdateBudget event,
    Emitter<BudgetState> emit,
  ) async {
    emit(const BudgetLoading());

    final result = await editBudgetUseCase(params: event.budget);

    if (result is Error<String>) {
      emit(BudgetError((result).failure.message));
      return;
    }

    emit(const BudgetUpdated());

    // Reload budgets after updating
    add(const LoadBudgets());
  }

  Future<void> _onDeleteBudget(
    DeleteBudget event,
    Emitter<BudgetState> emit,
  ) async {
    emit(const BudgetLoading());

    final result = await deleteBudgetUseCase(params: event.budgetId);

    if (result is Error) {
      emit(BudgetError(result.failure.message));
      return;
    }

    emit(const BudgetDeleted());

    // Reload budgets after deleting
    add(const LoadBudgets());
  }

  Future<void> _onLoadBudgetsByCategory(
    LoadBudgetsByCategory event,
    Emitter<BudgetState> emit,
  ) async {
    emit(const BudgetLoading());

    final budgetsResult =
        await getBudgetsByCategoryUseCase(params: event.categoryId);

    if (budgetsResult is Error<List<BudgetEntity>>) {
      emit(BudgetError((budgetsResult).failure.message));
      return;
    }

    final budgets = (budgetsResult as Success<List<BudgetEntity>>).data;

    // Get all transactions for budget progress calculation
    final transactionsResult = await getAllTransactionsUseCase();

    if (transactionsResult is Error<List<TransactionEntity>>) {
      emit(BudgetError((transactionsResult).failure.message));
      return;
    }

    final transactions =
        (transactionsResult as Success<List<TransactionEntity>>).data;

    emit(BudgetsLoaded(
      budgets: budgets,
      transactions: transactions,
    ));
  }

  Future<void> _onLoadActiveBudgets(
    LoadActiveBudgets event,
    Emitter<BudgetState> emit,
  ) async {
    emit(const BudgetLoading());

    final budgetsResult = await getActiveBudgetsUseCase();

    if (budgetsResult is Error<List<BudgetEntity>>) {
      emit(BudgetError((budgetsResult).failure.message));
      return;
    }

    final budgets = (budgetsResult as Success<List<BudgetEntity>>).data;

    // Get all transactions for budget progress calculation
    final transactionsResult = await getAllTransactionsUseCase();

    if (transactionsResult is Error<List<TransactionEntity>>) {
      emit(BudgetError((transactionsResult).failure.message));
      return;
    }

    final transactions =
        (transactionsResult as Success<List<TransactionEntity>>).data;

    emit(BudgetsLoaded(
      budgets: budgets,
      transactions: transactions,
    ));
  }

  Future<void> _onCheckBudgetNotifications(
    CheckBudgetNotifications event,
    Emitter<BudgetState> emit,
  ) async {
    // Get active budgets for notification checking
    final budgetsResult = await getActiveBudgetsUseCase();

    if (budgetsResult is Error<List<BudgetEntity>>) {
      return;
    }

    // final budgets = (budgetsResult as Success<List<BudgetEntity>>).data;

    // Update state if we're already in a loaded state
    if (state is BudgetsLoaded) {
      final currentState = state as BudgetsLoaded;
      emit(currentState.copyWith(transactions: event.transactions));
    }
  }

  /// Handler for refreshing budgets when transactions change
  Future<void> _onRefreshBudgetsOnTransactionChange(
    RefreshBudgetsOnTransactionChange event,
    Emitter<BudgetState> emit,
  ) async {
    // Only proceed if we're already in a loaded state to avoid unnecessary loading indicators
    if (state is BudgetsLoaded) {
      // Get all transactions for budget progress calculation
      final transactionsResult = await getAllTransactionsUseCase();

      if (transactionsResult is Error<List<TransactionEntity>>) {
        return;
      }

      final transactions =
          (transactionsResult as Success<List<TransactionEntity>>).data;

      // Update the state with the new transactions
      final currentState = state as BudgetsLoaded;

      emit(currentState.copyWith(transactions: transactions));
    } else {
      // If we're not in a loaded state, just load everything
      add(const LoadBudgets());
    }
  }

  @override
  Future<void> close() {
    // Cancel any ongoing operations if needed
    return super.close();
  }
}
