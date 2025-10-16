import 'package:hive_ce/hive.dart';
import 'package:money_track/core/constants/db_constants.dart';
import 'package:money_track/core/error/failures.dart';
import 'package:money_track/core/widgets/logger_service.dart';
import 'package:money_track/features/budget/data/models/budget_model.dart';

abstract class BudgetLocalDataSource {
  /// Get all budgets
  Future<List<BudgetModel>> getAllBudgets();

  /// Add a new budget
  Future<String> addBudget(BudgetModel budget);

  /// Edit an existing budget
  Future<String> editBudget(BudgetModel budget);

  /// Delete a budget
  Future<void> deleteBudget(String budgetId);

  /// Get budgets by category
  Future<List<BudgetModel>> getBudgetsByCategory(String categoryId);

  /// Get active budgets
  Future<List<BudgetModel>> getActiveBudgets();
}

class BudgetLocalDataSourceImpl implements BudgetLocalDataSource {
  final HiveInterface hive;
  final LoggerService logger = LoggerService();

  BudgetLocalDataSourceImpl({required this.hive});

  @override
  Future<List<BudgetModel>> getAllBudgets() async {
    try {
      final budgetDb =
          await hive.openBox<BudgetModel>(DBConstants.budgetDbName);
      return budgetDb.values.toList();
    } catch (e) {
      logger.en(e.toString(), name: "Get all budgets Exception");
      throw DatabaseFailure(message: "Failed to get budgets: ${e.toString()}");
    }
  }

  @override
  Future<String> addBudget(BudgetModel budget) async {
    try {
      final budgetDb =
          await hive.openBox<BudgetModel>(DBConstants.budgetDbName);
      await budgetDb.put(budget.id, budget);
      return "success";
    } catch (e) {
      logger.en(e.toString(), name: "Add budget Exception");
      throw DatabaseFailure(message: "Failed to add budget: ${e.toString()}");
    }
  }

  @override
  Future<String> editBudget(BudgetModel budget) async {
    try {
      final budgetDb =
          await hive.openBox<BudgetModel>(DBConstants.budgetDbName);
      await budgetDb.put(budget.id, budget);
      return "success";
    } catch (e) {
      logger.en(e.toString(), name: "Edit budget Exception");
      throw DatabaseFailure(message: "Failed to edit budget: ${e.toString()}");
    }
  }

  @override
  Future<void> deleteBudget(String budgetId) async {
    try {
      final budgetDb =
          await hive.openBox<BudgetModel>(DBConstants.budgetDbName);
      await budgetDb.delete(budgetId);
    } catch (e) {
      logger.en(e.toString(), name: "Delete budget Exception");
      throw DatabaseFailure(
          message: "Failed to delete budget: ${e.toString()}");
    }
  }

  @override
  Future<List<BudgetModel>> getBudgetsByCategory(String categoryId) async {
    try {
      final budgetDb =
          await hive.openBox<BudgetModel>(DBConstants.budgetDbName);
      return budgetDb.values
          .where((budget) => budget.category.id == categoryId)
          .toList();
    } catch (e) {
      logger.en(e.toString(), name: "Get budgets by category Exception");
      throw DatabaseFailure(
          message: "Failed to get budgets by category: ${e.toString()}");
    }
  }

  @override
  Future<List<BudgetModel>> getActiveBudgets() async {
    try {
      final budgetDb =
          await hive.openBox<BudgetModel>(DBConstants.budgetDbName);
      return budgetDb.values.where((budget) => budget.isActive).toList();
    } catch (e) {
      logger.en(e.toString(), name: "Get active budgets Exception");
      throw DatabaseFailure(
          message: "Failed to get active budgets: ${e.toString()}");
    }
  }
}
