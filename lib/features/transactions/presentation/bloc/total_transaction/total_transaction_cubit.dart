import 'dart:developer';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:money_track/core/error/result.dart';
import 'package:money_track/domain/entities/category_entity.dart';
import 'package:money_track/domain/entities/transaction_entity.dart';
import 'package:money_track/domain/usecases/transaction/get_all_transactions_usecase.dart';

part 'total_transaction_state.dart';

class TotalTransactionCubit extends Cubit<TotalTransactionState> {
  final GetAllTransactionsUseCase getAllTransactionsUseCase;

  TotalTransactionCubit({required this.getAllTransactionsUseCase})
      : super(TotalTransactionInitial());

  getTotalAmount() async {
    emit(TotalTransactionLoading()); // Emit loading state
    double income = 0;
    double expense = 0;

    final result = await getAllTransactionsUseCase();

    if (result is Success<List<TransactionEntity>>) {
      final transactionList = result.data;

      for (var transaction in transactionList) {
        log('Transaction: \\${transaction.id}, type: \\${transaction.transactionType} (runtimeType: \\${transaction.transactionType.runtimeType}), amount: \\${transaction.amount}',
            name: 'transaction_debug');
        if (transaction.transactionType == TransactionType.expense) {
          expense = expense + transaction.amount;
        } else {
          income = income + transaction.amount;
        }
      }

      log(income.toString(), name: "total income");
      log(expense.toString(), name: "total expense");
      emit(TotalTransactionSuccess(totalIncome: income, totalExpense: expense));
    } else if (result is Error<List<TransactionEntity>>) {
      emit(TotalTransactionError(message: result.failure.message));
    }
  }
}
