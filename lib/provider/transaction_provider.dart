import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:money_track/models/transaction_model/transaction_model.dart';

class ProviderTransaction extends ChangeNotifier {
  String transactionDbName = 'Transaction-database';
  List<TransactionModel> transactionListProvider = [];
  Future<void> addTransaction(TransactionModel obj) async {
    //to get anything in hive we need to open the hive , so here i am opening the hive database
    final transactionDb =
        await Hive.openBox<TransactionModel>(transactionDbName);
    //here i am putting a key value db model into the database ,
    //it is future function thats why added await
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
    transactionListProvider.addAll(list);
    notifyListeners();
    // transactionListNotifier.value.clear();
    // transactionListNotifier.value.addAll(list);
    // incomeAndExpense();
    // recentTransactionList();
    // transactionListNotifier.notifyListeners();
    // overViewListNotifier.notifyListeners();
  }
}
