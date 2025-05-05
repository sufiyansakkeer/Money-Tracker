import 'package:money_track/core/error/result.dart';
import 'package:money_track/core/use_cases/use_case.dart';
import 'package:money_track/features/budget/domain/repositories/budget_repository.dart';

/// Use case for deleting a budget
class DeleteBudgetUseCase implements UseCase<Result<void>, String> {
  final BudgetRepository repository;

  DeleteBudgetUseCase(this.repository);

  @override
  Future<Result<void>> call({String? params}) {
    if (params == null) {
      throw ArgumentError('Budget ID cannot be null');
    }
    return repository.deleteBudget(params);
  }
}
