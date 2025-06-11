import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:money_track/core/error/result.dart';
import 'package:money_track/core/logging/app_logger.dart';
import 'package:money_track/domain/entities/transaction_entity.dart';
import 'package:money_track/domain/usecases/transaction/get_all_transactions_usecase.dart';
import 'package:money_track/features/budget/domain/entities/budget_entity.dart';
import 'package:money_track/features/budget/domain/services/budget_notification_service.dart';
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
  final BudgetNotificationService notificationService;

  BudgetBloc({
    required this.getAllBudgetsUseCase,
    required this.addBudgetUseCase,
    required this.editBudgetUseCase,
    required this.deleteBudgetUseCase,
    required this.getBudgetsByCategoryUseCase,
    required this.getActiveBudgetsUseCase,
    required this.getAllTransactionsUseCase,
    required this.notificationService,
  }) : super(const BudgetInitial()) {
    AppLogger().info('BudgetBloc initialized', tag: 'BUDGET_BLOC');
    
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
    AppLogger().blocEvent('BudgetBloc', 'LoadBudgets');
    emit(const BudgetLoading());

    // Get all budgets
    final budgetsResult = await getAllBudgetsUseCase();

    if (budgetsResult is Error<List<BudgetEntity>>) {
      AppLogger().error('Failed to load budgets: ${(budgetsResult).failure.message}', 
        tag: 'BUDGET_BLOC');
      emit(BudgetError((budgetsResult).failure.message));
      return;
    }

    final budgets = (budgetsResult as Success<List<BudgetEntity>>).data;
    AppLogger().debug('Loaded ${budgets.length} budgets', tag: 'BUDGET_BLOC');

    // Get all transactions for budget progress calculation
    final transactionsResult = await getAllTransactionsUseCase();

    if (transactionsResult is Error<List<TransactionEntity>>) {
      AppLogger().error('Failed to load transactions for budget calculation: ${(transactionsResult).failure.message}', 
        tag: 'BUDGET_BLOC');
      emit(BudgetError((transactionsResult).failure.message));
      return;
    }

    final transactions = (transactionsResult as Success<List<TransactionEntity>>).data;
    AppLogger().debug('Loaded ${transactions.length} transactions for budget calculation', 
      tag: 'BUDGET_BLOC');

    AppLogger().blocState('BudgetBloc', 'BudgetsLoaded', 
      data: {'budgetCount': budgets.length, 'transactionCount': transactions.length});
    emit(BudgetsLoaded(
      budgets: budgets,
      transactions: transactions,
    ));

    // Check for budget notifications
    AppLogger().debug('Checking budget notifications', tag: 'BUDGET_BLOC');
    await notificationService.checkBudgetsAndNotify(budgets, transactions);
  }

  Future<void> _onAddBudget(
    AddBudget event,
    Emitter<BudgetState> emit,
  ) async {
    AppLogger().blocEvent('BudgetBloc', 'AddBudget', 
      data: {'budgetName': event.budget.name, 'amount': event.budget.amount});
    emit(const BudgetLoading());

    final result = await addBudgetUseCase(params: event.budget);

    if (result is Error<String>) {
      AppLogger().error('Failed to add budget: ${(result).failure.message}', 
        tag: 'BUDGET_BLOC');
      emit(BudgetError((result).failure.message));
      return;
    }

    AppLogger().info('Budget added successfully', tag: 'BUDGET_BLOC');
    emit(const BudgetAdded());

    // Reload budgets after adding
    add(const LoadBudgets());
  }

  Future<void> _onUpdateBudget(
    UpdateBudget event,
    Emitter<BudgetState> emit,
  ) async {
    AppLogger().blocEvent('BudgetBloc', 'UpdateBudget', 
      data: {'budgetId': event.budget.id, 'budgetName': event.budget.name});
    emit(const BudgetLoading());

    final result = await editBudgetUseCase(params: event.budget);

    if (result is Error<String>) {
      AppLogger().error('Failed to update budget: ${(result).failure.message}', 
        tag: 'BUDGET_BLOC');
      emit(BudgetError((result).failure.message));
      return;
    }

    AppLogger().info('Budget updated successfully', tag: 'BUDGET_BLOC');
    emit(const BudgetUpdated());

    // Reload budgets after updating
    add(const LoadBudgets());
  }

  Future<void> _onDeleteBudget(
    DeleteBudget event,
    Emitter<BudgetState> emit,
  ) async {
    AppLogger().blocEvent('BudgetBloc', 'DeleteBudget', 
      data: {'budgetId': event.budgetId});
    emit(const BudgetLoading());

    final result = await deleteBudgetUseCase(params: event.budgetId);

    if (result is Error) {
      AppLogger().error('Failed to delete budget: ${result.failure.message}', 
        tag: 'BUDGET_BLOC');
      emit(BudgetError(result.failure.message));
      return;
    }

    AppLogger().info('Budget deleted successfully', tag: 'BUDGET_BLOC');
    emit(const BudgetDeleted());

    // Reload budgets after deleting
    add(const LoadBudgets());
  }

  Future<void> _onLoadBudgetsByCategory(
    LoadBudgetsByCategory event,
    Emitter<BudgetState> emit,
  ) async {
    AppLogger().blocEvent('BudgetBloc', 'LoadBudgetsByCategory', 
      data: {'categoryId': event.categoryId});
    emit(const BudgetLoading());

    final budgetsResult = await getBudgetsByCategoryUseCase(params: event.categoryId);

    if (budgetsResult is Error<List<BudgetEntity>>) {
      AppLogger().error('Failed to load budgets by category: ${(budgetsResult).failure.message}', 
        tag: 'BUDGET_BLOC');
      emit(BudgetError((budgetsResult).failure.message));
      return;
    }

    final budgets = (budgetsResult as Success<List<BudgetEntity>>).data;
    AppLogger().debug('Loaded ${budgets.length} budgets for category', tag: 'BUDGET_BLOC');

    // Get all transactions for budget progress calculation
    final transactionsResult = await getAllTransactionsUseCase();

    if (transactionsResult is Error<List<TransactionEntity>>) {
      AppLogger().error('Failed to load transactions for budget calculation: ${(transactionsResult).failure.message}', 
        tag: 'BUDGET_BLOC');
      emit(BudgetError((transactionsResult).failure.message));
      return;
    }

    final transactions = (transactionsResult as Success<List<TransactionEntity>>).data;

    emit(BudgetsLoaded(
      budgets: budgets,
      transactions: transactions,
    ));
  }

  Future<void> _onLoadActiveBudgets(
    LoadActiveBudgets event,
    Emitter<BudgetState> emit,
  ) async {
    AppLogger().blocEvent('BudgetBloc', 'LoadActiveBudgets');
    emit(const BudgetLoading());

    final budgetsResult = await getActiveBudgetsUseCase();

    if (budgetsResult is Error<List<BudgetEntity>>) {
      AppLogger().error('Failed to load active budgets: ${(budgetsResult).failure.message}', 
        tag: 'BUDGET_BLOC');
      emit(BudgetError((budgetsResult).failure.message));
      return;
    }

    final budgets = (budgetsResult as Success<List<BudgetEntity>>).data;
    AppLogger().debug('Loaded ${budgets.length} active budgets', tag: 'BUDGET_BLOC');

    // Get all transactions for budget progress calculation
    final transactionsResult = await getAllTransactionsUseCase();

    if (transactionsResult is Error<List<TransactionEntity>>) {
      AppLogger().error('Failed to load transactions for budget calculation: ${(transactionsResult).failure.message}', 
        tag: 'BUDGET_BLOC');
      emit(BudgetError((transactionsResult).failure.message));
      return;
    }

    final transactions = (transactionsResult as Success<List<TransactionEntity>>).data;

    emit(BudgetsLoaded(
      budgets: budgets,
      transactions: transactions,
    ));
  }

  Future<void> _onCheckBudgetNotifications(
    CheckBudgetNotifications event,
    Emitter<BudgetState> emit,
  ) async {
    AppLogger().debug('Checking budget notifications', tag: 'BUDGET_BLOC');
    
    // Get active budgets for notification checking
    final budgetsResult = await getActiveBudgetsUseCase();

    if (budgetsResult is Error<List<BudgetEntity>>) {
      AppLogger().error('Failed to get budgets for notification check: ${(budgetsResult).failure.message}', 
        tag: 'BUDGET_BLOC');
      return;
    }

    final budgets = (budgetsResult as Success<List<BudgetEntity>>).data;

    // Check for budget notifications
    await notificationService.checkBudgetsAndNotify(budgets, event.transactions);

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
    AppLogger().info('Refreshing budgets due to transaction changes', tag: 'BUDGET_BLOC');

    // Only proceed if we're already in a loaded state to avoid unnecessary loading indicators
    if (state is BudgetsLoaded) {
      // Get all transactions for budget progress calculation
      final transactionsResult = await getAllTransactionsUseCase();

      if (transactionsResult is Error<List<TransactionEntity>>) {
        AppLogger().error('Failed to get transactions for budget refresh: ${(transactionsResult).failure.message}', 
          tag: 'BUDGET_BLOC');
        return;
      }

      final transactions = (transactionsResult as Success<List<TransactionEntity>>).data;
      AppLogger().debug('Loaded ${transactions.length} transactions for budget calculations', 
        tag: 'BUDGET_BLOC');

      // Update the state with the new transactions
      final currentState = state as BudgetsLoaded;
      AppLogger().debug('Current budgets count: ${currentState.budgets.length}', 
        tag: 'BUDGET_BLOC');

      emit(currentState.copyWith(transactions: transactions));

      // Check for budget notifications with the updated transactions
      if (currentState.budgets.isNotEmpty) {
        AppLogger().debug('Checking budget notifications for ${currentState.budgets.length} budgets', 
          tag: 'BUDGET_BLOC');
        await notificationService.checkBudgetsAndNotify(currentState.budgets, transactions);
      }
    } else {
      // If we're not in a loaded state, just load everything
      AppLogger().debug('Budget state is not loaded, loading everything', tag: 'BUDGET_BLOC');
      add(const LoadBudgets());
    }
  }
}