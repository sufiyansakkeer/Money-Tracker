import 'package:money_track/core/error/result.dart';
import 'package:money_track/core/use_cases/use_case.dart';
import 'package:money_track/features/budget/domain/entities/budget_entity.dart';
import 'package:money_track/features/budget/domain/repositories/budget_repository.dart';

/// Use case for getting active budgets
class GetActiveBudgetsUseCase implements UseCase<Result<List<BudgetEntity>>, void> {
  final BudgetRepository repository;

  GetActiveBudgetsUseCase(this.repository);

  @override
  Future<Result<List<BudgetEntity>>> call({void params}) {
    return repository.getActiveBudgets();
  }
}
