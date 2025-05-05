import 'package:money_track/core/error/result.dart';
import 'package:money_track/core/use_cases/use_case.dart';
import 'package:money_track/features/budget/domain/entities/budget_entity.dart';
import 'package:money_track/features/budget/domain/repositories/budget_repository.dart';

/// Use case for getting budgets by category
class GetBudgetsByCategoryUseCase implements UseCase<Result<List<BudgetEntity>>, String> {
  final BudgetRepository repository;

  GetBudgetsByCategoryUseCase(this.repository);

  @override
  Future<Result<List<BudgetEntity>>> call({String? params}) {
    if (params == null) {
      throw ArgumentError('Category ID cannot be null');
    }
    return repository.getBudgetsByCategory(params);
  }
}
