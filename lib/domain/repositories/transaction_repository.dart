import 'package:money_track/core/error/result.dart';
import 'package:money_track/domain/entities/transaction_entity.dart';

/// Repository interface for transaction operations
abstract class TransactionRepository {
  /// Get all transactions
  Future<Result<List<TransactionEntity>>> getAllTransactions();
  
  /// Add a new transaction
  Future<Result<String>> addTransaction(TransactionEntity transaction);
  
  /// Edit an existing transaction
  Future<Result<String>> editTransaction(TransactionEntity transaction);
  
  /// Delete a transaction
  Future<Result<void>> deleteTransaction(String transactionId);
}
