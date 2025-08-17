import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:money_track/core/constants/db_constants.dart';
import 'package:money_track/core/error/failures.dart';

import 'package:money_track/data/models/transaction_model.dart';

abstract class TransactionLocalDataSource {
  /// Get all transactions from local database
  Future<List<TransactionModel>> getAllTransactions();

  /// Add a new transaction to local database
  Future<String> addTransaction(TransactionModel transaction);

  /// Edit an existing transaction in local database
  Future<String> editTransaction(TransactionModel transaction);

  /// Delete a transaction from local database
  Future<void> deleteTransaction(String transactionId);
}

class TransactionLocalDataSourceImpl implements TransactionLocalDataSource {
  final HiveInterface hive;

  TransactionLocalDataSourceImpl({required this.hive});

  @override
  Future<List<TransactionModel>> getAllTransactions() async {
    try {
      final transactionDb =
          await hive.openBox<TransactionModel>(DBConstants.transactionDbName);
      var list = transactionDb.values.toList();
      list.sort((a, b) => a.date.compareTo(b.date));
      final sortedList = list.reversed.toList();

      return sortedList;
    } catch (e) {
      throw DatabaseFailure(
          message: "Failed to get transactions: ${e.toString()}");
    }
  }

  @override
  Future<String> addTransaction(TransactionModel transaction) async {
    try {
      final transactionDb =
          await hive.openBox<TransactionModel>(DBConstants.transactionDbName);
      await transactionDb.put(transaction.id, transaction);

      return "success";
    } catch (e) {
      throw DatabaseFailure(
          message: "Failed to add transaction: ${e.toString()}");
    }
  }

  @override
  Future<String> editTransaction(TransactionModel transaction) async {
    try {
      final transactionDb =
          await hive.openBox<TransactionModel>(DBConstants.transactionDbName);
      await transactionDb.put(transaction.id, transaction);

      return "success";
    } catch (e) {
      throw DatabaseFailure(
          message: "Failed to edit transaction: ${e.toString()}");
    }
  }

  @override
  Future<void> deleteTransaction(String transactionId) async {
    try {
      final transactionDb =
          await hive.openBox<TransactionModel>(DBConstants.transactionDbName);
      await transactionDb.delete(transactionId);
    } catch (e) {
      throw DatabaseFailure(
          message: "Failed to delete transaction: ${e.toString()}");
    }
  }
}
