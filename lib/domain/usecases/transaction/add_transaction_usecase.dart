import 'package:money_track/core/error/result.dart';
import 'package:money_track/core/use_cases/use_case.dart';
import 'package:money_track/domain/entities/transaction_entity.dart';
import 'package:money_track/domain/repositories/transaction_repository.dart';

/// Use case for adding a new transaction
class AddTransactionUseCase
    implements UseCase<Result<String>, TransactionEntity> {
  final TransactionRepository repository;

  AddTransactionUseCase(this.repository);

  @override
  Future<Result<String>> call({TransactionEntity? params}) {
    if (params == null) {
      throw ArgumentError('TransactionEntity cannot be null');
    }
    return repository.addTransaction(params);
  }
}
