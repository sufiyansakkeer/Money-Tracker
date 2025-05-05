import 'package:money_track/core/error/result.dart';
import 'package:money_track/core/use_cases/use_case.dart';
import 'package:money_track/domain/entities/transaction_entity.dart';
import 'package:money_track/domain/repositories/transaction_repository.dart';

/// Use case for getting all transactions
class GetAllTransactionsUseCase
    implements UseCase<Result<List<TransactionEntity>>, NoParams> {
  final TransactionRepository repository;

  GetAllTransactionsUseCase(this.repository);

  @override
  Future<Result<List<TransactionEntity>>> call({NoParams? params}) {
    return repository.getAllTransactions();
  }
}
