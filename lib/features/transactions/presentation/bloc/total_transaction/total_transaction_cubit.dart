import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:money_track/core/error/failures.dart';
import 'package:money_track/core/logging/app_logger.dart';
import 'package:money_track/domain/entities/category_entity.dart';
import 'package:money_track/domain/entities/transaction_entity.dart';
import 'package:money_track/domain/usecases/transaction/get_all_transactions_usecase.dart';

part 'total_transaction_state.dart';

/// Enhanced TotalTransactionCubit with better error handling and state management
class TotalTransactionCubit extends Cubit<TotalTransactionState> {
  final GetAllTransactionsUseCase _getAllTransactionsUseCase;

  TotalTransactionCubit({
    required GetAllTransactionsUseCase getAllTransactionsUseCase,
  })  : _getAllTransactionsUseCase = getAllTransactionsUseCase,
        super(const TotalTransactionInitial()) {
    AppLogger().info('TotalTransactionCubit initialized',
        tag: 'TOTAL_TRANSACTION_CUBIT');
  }

  /// Calculate total amounts with enhanced error handling
  Future<void> calculateTotalAmounts() async {
    if (state is TotalTransactionLoading) {
      AppLogger().debug('Calculation already in progress, skipping',
          tag: 'TOTAL_TRANSACTION_CUBIT');
      return; // Prevent multiple calls
    }

    AppLogger().debug('Starting total amounts calculation',
        tag: 'TOTAL_TRANSACTION_CUBIT');
    emit(const TotalTransactionLoading());

    try {
      final result = await _getAllTransactionsUseCase();

      result.fold(
        (transactions) {
          final totals = _calculateTotals(transactions);
          AppLogger().info(
              'Total calculation completed - Income: \\${totals.income}, Expense: \\${totals.expense}, Balance: \\${totals.balance}, Count: \\${transactions.length}',
              tag: 'TOTAL_TRANSACTION_CUBIT');
          print(
              '[DEBUG] TotalTransactionCubit emits: income=\\${totals.income}, expense=\\${totals.expense}, balance=\\${totals.balance}, count=\\${transactions.length}');
          emit(TotalTransactionSuccess(
            totalIncome: totals.income,
            totalExpense: totals.expense,
            balance: totals.balance,
            transactionCount: transactions.length,
          ));
        },
        (failure) {
          AppLogger().error('Failed to calculate totals: \\${failure.message}',
              tag: 'TOTAL_TRANSACTION_CUBIT');
          print(
              '[DEBUG] TotalTransactionCubit emits error: \\${failure.message}');
          emit(TotalTransactionError(failure: failure));
        },
      );
    } catch (e) {
      AppLogger().error('Unexpected error in calculateTotalAmounts: \\$e',
          tag: 'TOTAL_TRANSACTION_CUBIT', error: e);
      print('[DEBUG] TotalTransactionCubit emits unexpected error: \\$e');
      emit(TotalTransactionError(
        failure: DatabaseFailure(message: 'Unexpected error: \\$e'),
      ));
    }
  }

  /// Refresh totals (useful for pull-to-refresh)
  Future<void> refreshTotals() async {
    AppLogger().debug('Refreshing totals', tag: 'TOTAL_TRANSACTION_CUBIT');
    await calculateTotalAmounts();
  }

  /// Calculate totals from transaction list
  ({double income, double expense, double balance}) _calculateTotals(
    List<TransactionEntity> transactions,
  ) {
    AppLogger().debug(
        'Calculating totals for ${transactions.length} transactions',
        tag: 'TOTAL_TRANSACTION_CUBIT');

    double income = 0;
    double expense = 0;

    for (final transaction in transactions) {
      if (transaction.transactionType == TransactionType.expense) {
        expense += transaction.amount;
      } else {
        income += transaction.amount;
      }
    }

    final balance = income - expense;

    AppLogger().debug(
        'Calculation results - Income: $income, Expense: $expense, Balance: $balance',
        tag: 'TOTAL_TRANSACTION_CUBIT');

    return (
      income: income,
      expense: expense,
      balance: balance,
    );
  }

  /// Reset state to initial
  void reset() {
    AppLogger()
        .debug('Resetting state to initial', tag: 'TOTAL_TRANSACTION_CUBIT');
    emit(const TotalTransactionInitial());
  }

  /// Legacy method for backward compatibility
  Future<void> getTotalAmount() async {
    AppLogger()
        .debug('Legacy getTotalAmount called', tag: 'TOTAL_TRANSACTION_CUBIT');
    await calculateTotalAmounts();
  }
}
