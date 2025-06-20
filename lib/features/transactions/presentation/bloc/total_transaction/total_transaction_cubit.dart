import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:money_track/core/error/failures.dart';
import 'package:money_track/domain/entities/category_entity.dart';
import 'package:money_track/domain/entities/transaction_entity.dart';
import 'package:money_track/domain/usecases/transaction/get_all_transactions_usecase.dart';

part 'total_transaction_state.dart';

class TotalTransactionCubit extends Cubit<TotalTransactionState> {
  final GetAllTransactionsUseCase _getAllTransactionsUseCase;

  TotalTransactionCubit({
    required GetAllTransactionsUseCase getAllTransactionsUseCase,
  })  : _getAllTransactionsUseCase = getAllTransactionsUseCase,
        super(const TotalTransactionInitial());

  /// Calculate total amounts with enhanced error handling
  Future<void> calculateTotalAmounts() async {
    if (state is TotalTransactionLoading) {
      return; // Prevent multiple calls
    }

    emit(const TotalTransactionLoading());

    try {
      final result = await _getAllTransactionsUseCase();

      result.fold(
        (transactions) {
          final totals = _calculateTotals(transactions);
          emit(TotalTransactionSuccess(
            totalIncome: totals.income,
            totalExpense: totals.expense,
            balance: totals.balance,
            transactionCount: transactions.length,
          ));
        },
        (failure) {
          emit(TotalTransactionError(failure: failure));
        },
      );
    } catch (e) {
      emit(TotalTransactionError(
        failure: DatabaseFailure(message: 'Unexpected error: $e'),
      ));
    }
  }

  /// Refresh totals (useful for pull-to-refresh)
  Future<void> refreshTotals() async {
    await calculateTotalAmounts();
  }

  /// Calculate totals from transaction list
  ({double income, double expense, double balance}) _calculateTotals(
    List<TransactionEntity> transactions,
  ) {
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

    return (
      income: income,
      expense: expense,
      balance: balance,
    );
  }

  /// Reset state to initial
  void reset() {
    emit(const TotalTransactionInitial());
  }

  /// Legacy method for backward compatibility
  Future<void> getTotalAmount() async {
    await calculateTotalAmounts();
  }
}
