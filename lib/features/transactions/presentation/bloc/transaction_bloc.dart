import 'dart:developer';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:money_track/domain/entities/category_entity.dart';
import 'package:money_track/domain/entities/transaction_entity.dart';
import 'package:money_track/domain/usecases/transaction/add_transaction_usecase.dart';
import 'package:money_track/domain/usecases/transaction/get_all_transactions_usecase.dart';

part 'transaction_event.dart';
part 'transaction_state.dart';

class TransactionBloc extends Bloc<TransactionEvent, TransactionState> {
  final GetAllTransactionsUseCase getAllTransactionsUseCase;
  final AddTransactionUseCase addTransactionUseCase;

  TransactionBloc({
    required this.getAllTransactionsUseCase,
    required this.addTransactionUseCase,
  }) : super(TransactionInitial()) {
    on<GetAllTransactionsEvent>((event, emit) async {
      emit(TransactionLoading());
      final result = await getAllTransactionsUseCase();

      result.fold(
        (success) => emit(TransactionLoaded(transactionList: success)),
        (error) => emit(TransactionError(message: error.message)),
      );
    });

    on<AddTransactionEvent>((event, emit) async {
      try {
        double amount = double.tryParse(event.amount) ?? 0;

        final transaction = TransactionEntity(
          id: DateTime.now().microsecondsSinceEpoch.toString(),
          amount: amount,
          date: event.date,
          categoryType: event.categoryType,
          transactionType: event.isExpense
              ? TransactionType.expense
              : TransactionType.income,
          category: event.categoryModel,
          notes: event.description,
        );

        final result = await addTransactionUseCase(params: transaction);

        result.fold(
          (success) => add(GetAllTransactionsEvent()),
          (error) => emit(TransactionError(message: error.message)),
        );
      } catch (e) {
        log(e.toString(), name: "Add transaction event Exception");
        emit(TransactionError(message: e.toString()));
      }
    });

    // Add other event handlers here
  }
}

// Extension is no longer needed as fold is implemented in the Result class
