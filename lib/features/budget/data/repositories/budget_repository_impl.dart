import 'package:money_track/core/error/failures.dart';
import 'package:money_track/core/error/result.dart';
import 'package:money_track/features/budget/data/datasources/budget_local_datasource.dart';
import 'package:money_track/features/budget/data/models/budget_model.dart';
import 'package:money_track/features/budget/domain/entities/budget_entity.dart';
import 'package:money_track/features/budget/domain/repositories/budget_repository.dart';

class BudgetRepositoryImpl implements BudgetRepository {
  final BudgetLocalDataSource localDataSource;

  BudgetRepositoryImpl({required this.localDataSource});

  @override
  Future<Result<List<BudgetEntity>>> getAllBudgets() async {
    try {
      final budgetModels = await localDataSource.getAllBudgets();
      final budgets = budgetModels.map((model) => model.toEntity()).toList();
      return Success(budgets);
    } catch (e) {
      return Error(DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<String>> addBudget(BudgetEntity budget) async {
    try {
      final budgetModel = BudgetModel.fromEntity(budget);
      final result = await localDataSource.addBudget(budgetModel);
      return Success(result);
    } catch (e) {
      return Error(DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<String>> editBudget(BudgetEntity budget) async {
    try {
      final budgetModel = BudgetModel.fromEntity(budget);
      final result = await localDataSource.editBudget(budgetModel);
      return Success(result);
    } catch (e) {
      return Error(DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<void>> deleteBudget(String budgetId) async {
    try {
      await localDataSource.deleteBudget(budgetId);
      return const Success(null);
    } catch (e) {
      return Error(DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<List<BudgetEntity>>> getBudgetsByCategory(String categoryId) async {
    try {
      final budgetModels = await localDataSource.getBudgetsByCategory(categoryId);
      final budgets = budgetModels.map((model) => model.toEntity()).toList();
      return Success(budgets);
    } catch (e) {
      return Error(DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<List<BudgetEntity>>> getActiveBudgets() async {
    try {
      final budgetModels = await localDataSource.getActiveBudgets();
      final budgets = budgetModels.map((model) => model.toEntity()).toList();
      return Success(budgets);
    } catch (e) {
      return Error(DatabaseFailure(message: e.toString()));
    }
  }
}
