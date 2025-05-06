import 'package:money_track/core/error/result.dart';
import 'package:money_track/features/budget/domain/entities/budget_entity.dart';

/// Repository interface for budget operations
abstract class BudgetRepository {
  /// Get all budgets
  Future<Result<List<BudgetEntity>>> getAllBudgets();
  
  /// Add a new budget
  Future<Result<String>> addBudget(BudgetEntity budget);
  
  /// Edit an existing budget
  Future<Result<String>> editBudget(BudgetEntity budget);
  
  /// Delete a budget
  Future<Result<void>> deleteBudget(String budgetId);
  
  /// Get budgets by category
  Future<Result<List<BudgetEntity>>> getBudgetsByCategory(String categoryId);
  
  /// Get active budgets
  Future<Result<List<BudgetEntity>>> getActiveBudgets();
}
