import 'package:hive_flutter/hive_flutter.dart';
import 'package:money_track/core/constants/db_constants.dart';
import 'package:money_track/core/error/failures.dart';
import 'package:money_track/core/logging/app_logger.dart';
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

  TransactionLocalDataSourceImpl({required this.hive}) {
    AppLogger().debug('TransactionLocalDataSourceImpl initialized', tag: 'TRANSACTION_DATASOURCE');
  }

  @override
  Future<List<TransactionModel>> getAllTransactions() async {
    AppLogger().debug('Getting all transactions from Hive', tag: 'TRANSACTION_DATASOURCE');
    
    try {
      final transactionDb = await hive.openBox<TransactionModel>(DBConstants.transactionDbName);
      var list = transactionDb.values.toList();
      list.sort((a, b) => a.date.compareTo(b.date));
      final sortedList = list.reversed.toList();
      
      AppLogger().debug('Retrieved ${sortedList.length} transactions from Hive', 
        tag: 'TRANSACTION_DATASOURCE');
      return sortedList;
    } catch (e) {
      AppLogger().error('Failed to get all transactions from Hive: $e', 
        tag: 'TRANSACTION_DATASOURCE', error: e);
      throw DatabaseFailure(message: "Failed to get transactions: ${e.toString()}");
    }
  }

  @override
  Future<String> addTransaction(TransactionModel transaction) async {
    AppLogger().debug('Adding transaction to Hive with ID: ${transaction.id}', 
      tag: 'TRANSACTION_DATASOURCE');
    
    try {
      final transactionDb = await hive.openBox<TransactionModel>(DBConstants.transactionDbName);
      await transactionDb.put(transaction.id, transaction);
      
      AppLogger().info('Transaction added to Hive successfully', tag: 'TRANSACTION_DATASOURCE');
      return "success";
    } catch (e) {
      AppLogger().error('Failed to add transaction to Hive: $e', 
        tag: 'TRANSACTION_DATASOURCE', error: e);
      throw DatabaseFailure(message: "Failed to add transaction: ${e.toString()}");
    }
  }

  @override
  Future<String> editTransaction(TransactionModel transaction) async {
    AppLogger().debug('Editing transaction in Hive with ID: ${transaction.id}', 
      tag: 'TRANSACTION_DATASOURCE');
    
    try {
      final transactionDb = await hive.openBox<TransactionModel>(DBConstants.transactionDbName);
      await transactionDb.put(transaction.id, transaction);
      
      AppLogger().info('Transaction edited in Hive successfully', tag: 'TRANSACTION_DATASOURCE');
      return "success";
    } catch (e) {
      AppLogger().error('Failed to edit transaction in Hive: $e', 
        tag: 'TRANSACTION_DATASOURCE', error: e);
      throw DatabaseFailure(message: "Failed to edit transaction: ${e.toString()}");
    }
  }

  @override
  Future<void> deleteTransaction(String transactionId) async {
    AppLogger().debug('Deleting transaction from Hive with ID: $transactionId', 
      tag: 'TRANSACTION_DATASOURCE');
    
    try {
      final transactionDb = await hive.openBox<TransactionModel>(DBConstants.transactionDbName);
      await transactionDb.delete(transactionId);
      
      AppLogger().info('Transaction deleted from Hive successfully', tag: 'TRANSACTION_DATASOURCE');
    } catch (e) {
      AppLogger().error('Failed to delete transaction from Hive: $e', 
        tag: 'TRANSACTION_DATASOURCE', error: e);
      throw DatabaseFailure(message: "Failed to delete transaction: ${e.toString()}");
    }
  }
}