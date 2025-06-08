import 'package:money_track/core/error/failures.dart';
import 'package:money_track/core/error/result.dart';
import 'package:money_track/core/logging/app_logger.dart';
import 'package:money_track/data/datasources/local/transaction_local_datasource.dart';
import 'package:money_track/data/models/transaction_model.dart';
import 'package:money_track/domain/entities/transaction_entity.dart';
import 'package:money_track/domain/repositories/transaction_repository.dart';

class TransactionRepositoryImpl implements TransactionRepository {
  final TransactionLocalDataSource localDataSource;

  TransactionRepositoryImpl({required this.localDataSource}) {
    AppLogger().debug('TransactionRepositoryImpl initialized', tag: 'TRANSACTION_REPO');
  }

  @override
  Future<Result<List<TransactionEntity>>> getAllTransactions() async {
    AppLogger().database('SELECT', 'transactions', data: {'operation': 'getAllTransactions'});
    
    try {
      final transactionModels = await localDataSource.getAllTransactions();
      final transactions = transactionModels.map((model) => model.toEntity()).toList();
      
      AppLogger().info('Retrieved ${transactions.length} transactions', tag: 'TRANSACTION_REPO');
      return Success(transactions);
    } catch (e) {
      AppLogger().error('Failed to get all transactions: $e', tag: 'TRANSACTION_REPO', error: e);
      return Error(DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<String>> addTransaction(TransactionEntity transaction) async {
    AppLogger().database('INSERT', 'transactions', data: {
      'transactionId': transaction.id,
      'amount': transaction.amount,
      'type': transaction.transactionType.toString()
    });
    
    try {
      final transactionModel = TransactionModel.fromEntity(transaction);
      final result = await localDataSource.addTransaction(transactionModel);
      
      AppLogger().info('Transaction added successfully with ID: $result', tag: 'TRANSACTION_REPO');
      return Success(result);
    } catch (e) {
      AppLogger().error('Failed to add transaction: $e', tag: 'TRANSACTION_REPO', error: e);
      return Error(DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<String>> editTransaction(TransactionEntity transaction) async {
    AppLogger().database('UPDATE', 'transactions', data: {
      'transactionId': transaction.id,
      'amount': transaction.amount,
      'type': transaction.transactionType.toString()
    });
    
    try {
      final transactionModel = TransactionModel.fromEntity(transaction);
      final result = await localDataSource.editTransaction(transactionModel);
      
      AppLogger().info('Transaction edited successfully with ID: $result', tag: 'TRANSACTION_REPO');
      return Success(result);
    } catch (e) {
      AppLogger().error('Failed to edit transaction: $e', tag: 'TRANSACTION_REPO', error: e);
      return Error(DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<void>> deleteTransaction(String transactionId) async {
    AppLogger().database('DELETE', 'transactions', data: {'transactionId': transactionId});
    
    try {
      await localDataSource.deleteTransaction(transactionId);
      
      AppLogger().info('Transaction deleted successfully with ID: $transactionId', tag: 'TRANSACTION_REPO');
      return const Success(null);
    } catch (e) {
      AppLogger().error('Failed to delete transaction: $e', tag: 'TRANSACTION_REPO', error: e);
      return Error(DatabaseFailure(message: e.toString()));
    }
  }
}