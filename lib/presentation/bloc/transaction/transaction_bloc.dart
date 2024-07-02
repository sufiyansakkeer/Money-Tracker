import 'dart:developer';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:money_track/models/categories_model/category_model.dart';
import 'package:money_track/models/transaction_model/transaction_model.dart';
import 'package:money_track/repository/transaction_repository.dart';

part 'transaction_event.dart';
part 'transaction_state.dart';

class TransactionBloc extends Bloc<TransactionEvent, TransactionState> {
  TransactionBloc() : super(TransactionInitial()) {
    on<GetAllTransaction>((event, emit) async {
      emit(TransactionLoading());
      List<TransactionModel>? res =
          await TransactionRepository().getAllTransaction();
      if (res != null) {
        emit(TransactionLoaded(transactionList: res));
      } else {
        emit(TransactionError());
      }
    });

    on<AddTransactionEvent>((event, emit) async {
      try {
        double amount = double.tryParse(event.amount) ?? 0;

        TransactionModel model = TransactionModel(
          amount: amount,
          date: event.date,
          categoryType: event.categoryType,
          transactionType: event.isExpense
              ? TransactionType.expense
              : TransactionType.income,
          categoryModel: event.categoryModel,
          notes: event.description,
          id: DateTime.now().microsecondsSinceEpoch.toString(),
        );
        String res = await TransactionRepository().addTransaction(model);
        if (res == "success") {
          add(GetAllTransaction());
        }
      } catch (e) {
        log(e.toString(), name: "Add transaction event Exception");
      }
    });
    on<DeleteTransactionEvent>((event, emit) async {
      try {
        await TransactionRepository().deleteTransaction(event.transactionModel);
        add(GetAllTransaction());
      } catch (e) {
        log(e.toString(), name: "Add transaction event Exception");
      }
    });

    on<EditTransactionEvent>((event, emit) async {
      try {
        double amount = double.tryParse(event.amount) ?? 0;

        TransactionModel model = TransactionModel(
          id: event.id,
          amount: amount,
          date: event.date,
          categoryType: event.categoryType,
          transactionType: event.isExpense
              ? TransactionType.expense
              : TransactionType.income,
          categoryModel: event.categoryModel,
          notes: event.description,
        );
        String res = await TransactionRepository().editTransaction(model);
        if (res == "success") {
          add(GetAllTransaction());
        }
      } catch (e) {
        log(e.toString(), name: "Add transaction event Exception");
      }
    });
  }
}
