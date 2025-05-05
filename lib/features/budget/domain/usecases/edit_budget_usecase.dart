import 'package:money_track/core/error/result.dart';
import 'package:money_track/core/use_cases/use_case.dart';
import 'package:money_track/features/budget/domain/entities/budget_entity.dart';
import 'package:money_track/features/budget/domain/repositories/budget_repository.dart';

/// Use case for editing an existing budget
class EditBudgetUseCase implements UseCase<Result<String>, BudgetEntity> {
  final BudgetRepository repository;

  EditBudgetUseCase(this.repository);

  @override
  Future<Result<String>> call({BudgetEntity? params}) {
    if (params == null) {
      throw ArgumentError('Budget cannot be null');
    }
    return repository.editBudget(params);
  }
}
