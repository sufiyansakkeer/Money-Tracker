import 'package:flutter/cupertino.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:money_track/models/transaction_model/transaction_model.dart';

const Transaction_DB_Name = 'Transaction-database';

abstract class TransactionDBFunction {
  Future<void> addTransaction(TransactionModel obj);
  Future<List<TransactionModel>> getAllTransaction();
  // Future<void> editTransaction(TransactionModel obj);
  Future<void> deleteTransaction(TransactionModel obj);
}

class TransactionDB implements TransactionDBFunction {
  //it is a named constructor we created,which is private
  TransactionDB._internal();
  //using the above constructor we creating the object,
  //here we used singleton to get one single instance only that is one object
  static TransactionDB instance = TransactionDB._internal();
//to ensure we getting single ton we use factory
  factory TransactionDB() {
    return instance;
  }

  ValueNotifier<List<TransactionModel>> transactionListNotifier =
      ValueNotifier([]);

  @override
  Future<void> addTransaction(TransactionModel obj) async {
    //to get anything in hive we need to open the hive , so here i am opening the hive database
    final transactionDb =
        await Hive.openBox<TransactionModel>(Transaction_DB_Name);
    //here i am putting a key value db model into the database ,
    //it is future function thats why added await
    await transactionDb.put(obj.id, obj);
    refreshUi();
  }

  Future<void> refreshUi() async {
    final _list = await getAllTransaction();
    //here we use sorting to make the current transaction to be shown first
    _list.sort(
        ((firstDate, secondDate) => secondDate.date.compareTo(firstDate.date)));
    transactionListNotifier.value.clear();
    transactionListNotifier.value.addAll(_list);
    transactionListNotifier.notifyListeners();
  }

  @override
  Future<List<TransactionModel>> getAllTransaction() async {
    final transactionDb =
        await Hive.openBox<TransactionModel>(Transaction_DB_Name);
    return transactionDb.values.toList().reversed.toList();
  }

  @override
  Future<void> deleteTransaction(TransactionModel obj) async {
    final transactionDb =
        await Hive.openBox<TransactionModel>(Transaction_DB_Name);

    await transactionDb.delete(obj.id);
    refreshUi();
  }
}
