import 'package:money_track/core/error/result.dart';
import 'package:money_track/features/groups/domain/entities/shared_expense_entity.dart';

abstract class SharedExpenseRepository {
  Future<Result<List<SharedExpenseEntity>>> getSharedExpenses();
  Future<Result<List<SharedExpenseEntity>>> getSharedExpensesByGroup(
      String groupId);
  Future<Result<SharedExpenseEntity?>> getSharedExpenseById(String expenseId);
  Future<Result<void>> addSharedExpense(SharedExpenseEntity expense);
  Future<Result<void>> updateSharedExpense(SharedExpenseEntity expense);
  Future<Result<void>> deleteSharedExpense(String expenseId);
  Future<Result<List<SharedExpenseEntity>>> getSharedExpensesByDateRange(
    DateTime startDate,
    DateTime endDate,
  );
  Future<Result<List<SharedExpenseEntity>>> getSharedExpensesByCategory(
      String categoryId);
  Future<Result<List<SharedExpenseEntity>>> searchSharedExpenses(String query);
}
