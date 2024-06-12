import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:money_track/models/categories_model/category_model.dart';

import 'package:money_track/models/transaction_model/transaction_model.dart';

class ProviderTransaction extends ChangeNotifier {
  double incomeTotal = 0;
  double expenseTotal = 0;
  double totalBalance = 0;
  String transactionDbName = 'Transaction-database';
  String showCategory = ("All");
  String dateFilterTitle = "All";
  List<TransactionModel> transactionListProvider = [];
  List<TransactionModel> overviewGraphTransactions = [];
  List<TransactionModel> overviewTransactions = [];

  set setOverviewTransactions(List<TransactionModel> overViewNewList) {
    overviewTransactions = overViewNewList;

    notifyListeners();
  }

  set setOverViewGraphTransactions(
      List<TransactionModel> overViewGraphTransactionsNewList) {
    overviewGraphTransactions = overViewGraphTransactionsNewList;

    notifyListeners();
  }

  set setDateFilterTitle(String dateFilterTitleNewList) {
    dateFilterTitle = dateFilterTitleNewList;

    notifyListeners();
  }

  set setShowCategory(String overShowCategory) {
    showCategory = overShowCategory;
    notifyListeners();
  }

  set setTransactionListNotifier(List<TransactionModel> transactionNewList) {
    transactionListProvider = transactionNewList;
    notifyListeners();
  }

  Future<void> addTransaction(TransactionModel obj) async {
    final transactionDb =
        await Hive.openBox<TransactionModel>(transactionDbName);

    await transactionDb.put(obj.id, obj);
    refreshUi();
  }

  Future<void> deleteTransaction(TransactionModel obj) async {
    final transactionDb =
        await Hive.openBox<TransactionModel>(transactionDbName);

    await transactionDb.delete(obj.id);
    refreshUi();
  }

  Future<void> editTransaction(TransactionModel value) async {
    final transactionDb =
        await Hive.openBox<TransactionModel>(transactionDbName);
    await transactionDb.put(value.id, value);

    refreshUi();
  }

  Future<List<TransactionModel>> getAllTransaction() async {
    final transactionDb =
        await Hive.openBox<TransactionModel>(transactionDbName);
    return transactionDb.values.toList().reversed.toList();
  }

  Future<void> refreshUi() async {
    final list = await getAllTransaction();
    //here we use sorting to make the current transaction to be shown first
    list.sort(
        ((firstDate, secondDate) => secondDate.date.compareTo(firstDate.date)));
    transactionListProvider.clear();
    transactionListProvider.addAll(list);
    overviewTransactions = transactionListProvider;
    overviewGraphTransactions = transactionListProvider;
    log(transactionListProvider.toString());
    incomeAndExpense();
    notifyListeners();
  }

  void incomeAndExpense() {
    incomeTotal = 0;
    expenseTotal = 0;
    totalBalance = 0;
    final List<TransactionModel> value = transactionListProvider;

    for (int i = 0; i < value.length; i++) {
      if (TransactionType.income == value[i].categoryModel.type) {
        incomeTotal = incomeTotal + value[i].amount;
      } else {
        expenseTotal = expenseTotal + value[i].amount;
      }
    }
    totalBalance = incomeTotal - expenseTotal;

    notifyListeners();
  }
}
