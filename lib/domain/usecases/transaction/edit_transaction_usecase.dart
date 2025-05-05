import 'package:money_track/core/error/failures.dart';
import 'package:money_track/core/error/result.dart'; // Keep this import
import 'package:money_track/core/use_cases/use_case.dart';
import 'package:money_track/domain/entities/transaction_entity.dart';
import 'package:money_track/domain/repositories/transaction_repository.dart';

class EditTransactionUseCase
    implements UseCase<Result<String>, TransactionEntity> {
  // Changed Result<void> to Result<String>
  // Corrected Result type
  final TransactionRepository repository;

  EditTransactionUseCase({required this.repository});

  @override
  Future<Result<String>> call({TransactionEntity? params}) async {
    // Changed Result<void> to Result<String>
    // Corrected signature and Result type
    // Assert params is not null, as editing requires a transaction
    assert(params != null, 'TransactionEntity cannot be null for editing');
    // Assuming the repository has an 'editTransaction' method
    return await repository.editTransaction(params!); // Use non-null assertion
  }
}
