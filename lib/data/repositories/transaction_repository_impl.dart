import 'package:money_track/core/error/failures.dart';
import 'package:money_track/core/error/result.dart';
import 'package:money_track/data/datasources/local/transaction_local_datasource.dart';
import 'package:money_track/data/models/transaction_model.dart';
import 'package:money_track/domain/entities/transaction_entity.dart';
import 'package:money_track/domain/repositories/transaction_repository.dart';

class TransactionRepositoryImpl implements TransactionRepository {
  final TransactionLocalDataSource localDataSource;

  TransactionRepositoryImpl({required this.localDataSource});

  @override
  Future<Result<List<TransactionEntity>>> getAllTransactions() async {
    try {
      final transactionModels = await localDataSource.getAllTransactions();
      final transactions = transactionModels.map((model) => model.toEntity()).toList();
      return Success(transactions);
    } catch (e) {
      return Error(DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<String>> addTransaction(TransactionEntity transaction) async {
    try {
      final transactionModel = TransactionModel.fromEntity(transaction);
      final result = await localDataSource.addTransaction(transactionModel);
      return Success(result);
    } catch (e) {
      return Error(DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<String>> editTransaction(TransactionEntity transaction) async {
    try {
      final transactionModel = TransactionModel.fromEntity(transaction);
      final result = await localDataSource.editTransaction(transactionModel);
      return Success(result);
    } catch (e) {
      return Error(DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<void>> deleteTransaction(String transactionId) async {
    try {
      await localDataSource.deleteTransaction(transactionId);
      return const Success(null);
    } catch (e) {
      return Error(DatabaseFailure(message: e.toString()));
    }
  }
}
