import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:money_track/core/constants/db_constants.dart';
import 'package:money_track/models/transaction_model/transaction_model.dart';

class TransactionRepository {
  String transactionDbName = DBConstants.transactionDbName;
  Future<List<TransactionModel>?> getAllTransaction() async {
    try {
      final transactionDb =
          await Hive.openBox<TransactionModel>(DBConstants.transactionDbName);
      return transactionDb.values.toList().reversed.toList();
    } catch (e) {
      if (kDebugMode) {
        log(e.toString(), name: "Get all transaction Exception");
      }
      return null;
    }
  }

  Future<void> addTransaction(TransactionModel obj) async {
    try {
      final transactionDb =
          await Hive.openBox<TransactionModel>(transactionDbName);

      await transactionDb.put(obj.id, obj);
    } catch (e) {
      if (kDebugMode) {
        log(e.toString(), name: "Add transaction Exception");
      }
    }
  }

  Future<void> deleteTransaction(TransactionModel obj) async {
    try {
      final transactionDb =
          await Hive.openBox<TransactionModel>(transactionDbName);

      await transactionDb.delete(obj.id);
    } catch (e) {
      if (kDebugMode) {
        log(e.toString(), name: "Delete transaction Exception");
      }
    }
  }
}
