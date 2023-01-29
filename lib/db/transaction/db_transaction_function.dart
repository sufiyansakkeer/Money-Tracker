import 'package:flutter/cupertino.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:money_track/Transaction/transaction_list.dart';
import 'package:money_track/db/transaction/income_and_expense.dart';

import 'package:money_track/models/transaction_model/transaction_model.dart';

abstract class TransactionDBFunction {
  Future<void> addTransaction(TransactionModel obj);

  Future<List<TransactionModel>> getAllTransaction();

  Future<void> editTransaction(TransactionModel value);

  Future<void> deleteTransaction(TransactionModel obj);
  // Future<void> resetApp();
}

class TransactionDB implements TransactionDBFunction {
//to ensure we getting single ton we use factory
  factory TransactionDB() {
    return instance;
  }

  //it is a named constructor we created,which is private
  TransactionDB._internal();

  //using the above constructor we creating the object,
  //here we used singleton to get one single instance only that is one object
  static TransactionDB instance = TransactionDB._internal();

  String transactionDbName = 'Transaction-database';
  ValueNotifier<List<TransactionModel>> transactionListNotifier =
      ValueNotifier([]);

  @override
  Future<void> deleteTransaction(TransactionModel obj) async {
    final transactionDb =
        await Hive.openBox<TransactionModel>(transactionDbName);

    await transactionDb.delete(obj.id);
    refreshUi();
  }

  @override
  Future<void> editTransaction(TransactionModel value) async {
    final transactionDb =
        await Hive.openBox<TransactionModel>(transactionDbName);
    await transactionDb.put(value.id, value);

    refreshUi();
  }

  @override
  Future<List<TransactionModel>> getAllTransaction() async {
    final transactionDb =
        await Hive.openBox<TransactionModel>(transactionDbName);
    return transactionDb.values.toList().reversed.toList();
  }

  @override
  Future<void> addTransaction(TransactionModel obj) async {
    //to get anything in hive we need to open the hive , so here i am opening the hive database
    final transactionDb =
        await Hive.openBox<TransactionModel>(transactionDbName);
    //here i am putting a key value db model into the database ,
    //it is future function thats why added await
    await transactionDb.put(obj.id, obj);
    refreshUi();
  }

  Future<void> refreshUi() async {
    final list = await getAllTransaction();
    //here we use sorting to make the current transaction to be shown first
    list.sort(
        ((firstDate, secondDate) => secondDate.date.compareTo(firstDate.date)));
    transactionListNotifier.value.clear();
    transactionListNotifier.value.addAll(list);
    incomeAndExpense();
    // recentTransactionList();
    transactionListNotifier.notifyListeners();
    overViewListNotifier.notifyListeners();
  }

  // @override
  Future<void> resetApp() async {
    // Clear all data from the boxes
    final transactionDb = await Hive.openBox(transactionDbName);
    for (final box in transactionDb.values) {
      await box.deleteFromDisk();
    }

    // Close all boxes
    await Hive.close();

    // Re-initialize Hive with the initial values
    await Hive.initFlutter();
    transactionListNotifier.notifyListeners();
    overViewListNotifier.notifyListeners();
  }
}
