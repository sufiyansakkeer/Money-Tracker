import 'package:money_track/core/error/result.dart';
import 'package:money_track/core/use_cases/use_case.dart';
import 'package:money_track/domain/repositories/transaction_repository.dart';

/// Use case for deleting a transaction
class DeleteTransactionUseCase implements UseCase<Result<void>, String> {
  final TransactionRepository repository;

  DeleteTransactionUseCase(this.repository);

  @override
  Future<Result<void>> call({String? params}) {
    if (params == null) {
      throw ArgumentError('Transaction ID cannot be null');
    }
    return repository.deleteTransaction(params);
  }
}
