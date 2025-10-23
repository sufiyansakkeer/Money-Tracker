import 'package:hive_ce/hive.dart';
import 'package:money_track/core/error/failures.dart';
import 'package:money_track/features/groups/data/models/shared_expense_model.dart';

abstract class SharedExpenseLocalDataSource {
  Future<List<SharedExpenseModel>> getSharedExpenses();
  Future<List<SharedExpenseModel>> getSharedExpensesByGroup(String groupId);
  Future<SharedExpenseModel?> getSharedExpenseById(String expenseId);
  Future<void> addSharedExpense(SharedExpenseModel expense);
  Future<void> updateSharedExpense(SharedExpenseModel expense);
  Future<void> deleteSharedExpense(String expenseId);
  Future<List<SharedExpenseModel>> getSharedExpensesByDateRange(
    DateTime startDate,
    DateTime endDate,
  );
  Future<List<SharedExpenseModel>> getSharedExpensesByCategory(String categoryId);
  Future<List<SharedExpenseModel>> searchSharedExpenses(String query);
}

class SharedExpenseLocalDataSourceImpl implements SharedExpenseLocalDataSource {
  final Box<SharedExpenseModel> expenseBox;

  SharedExpenseLocalDataSourceImpl(this.expenseBox);

  @override
  Future<List<SharedExpenseModel>> getSharedExpenses() async {
    try {
      final expenses = expenseBox.values.toList();
      // Sort by creation date (newest first)
      expenses.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return expenses;
    } catch (e) {
      throw DatabaseFailure(message: "Failed to get shared expenses: ${e.toString()}");
    }
  }

  @override
  Future<List<SharedExpenseModel>> getSharedExpensesByGroup(String groupId) async {
    try {
      final expenses = expenseBox.values
          .where((expense) => expense.groupId == groupId)
          .toList();
      // Sort by creation date (newest first)
      expenses.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return expenses;
    } catch (e) {
      throw DatabaseFailure(message: "Failed to get group expenses: ${e.toString()}");
    }
  }

  @override
  Future<SharedExpenseModel?> getSharedExpenseById(String expenseId) async {
    try {
      return expenseBox.get(expenseId);
    } catch (e) {
      throw DatabaseFailure(message: "Failed to get expense: ${e.toString()}");
    }
  }

  @override
  Future<void> addSharedExpense(SharedExpenseModel expense) async {
    try {
      await expenseBox.put(expense.id, expense);
    } catch (e) {
      throw DatabaseFailure(message: "Failed to add shared expense: ${e.toString()}");
    }
  }

  @override
  Future<void> updateSharedExpense(SharedExpenseModel expense) async {
    try {
      await expenseBox.put(expense.id, expense);
    } catch (e) {
      throw DatabaseFailure(message: "Failed to update shared expense: ${e.toString()}");
    }
  }

  @override
  Future<void> deleteSharedExpense(String expenseId) async {
    try {
      await expenseBox.delete(expenseId);
    } catch (e) {
      throw DatabaseFailure(message: "Failed to delete shared expense: ${e.toString()}");
    }
  }

  @override
  Future<List<SharedExpenseModel>> getSharedExpensesByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final expenses = expenseBox.values
          .where((expense) =>
              expense.createdAt.isAfter(startDate.subtract(const Duration(days: 1))) &&
              expense.createdAt.isBefore(endDate.add(const Duration(days: 1))))
          .toList();
      // Sort by creation date (newest first)
      expenses.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return expenses;
    } catch (e) {
      throw DatabaseFailure(message: "Failed to get expenses by date range: ${e.toString()}");
    }
  }

  @override
  Future<List<SharedExpenseModel>> getSharedExpensesByCategory(String categoryId) async {
    try {
      final expenses = expenseBox.values
          .where((expense) => expense.category.id == categoryId)
          .toList();
      // Sort by creation date (newest first)
      expenses.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return expenses;
    } catch (e) {
      throw DatabaseFailure(message: "Failed to get expenses by category: ${e.toString()}");
    }
  }

  @override
  Future<List<SharedExpenseModel>> searchSharedExpenses(String query) async {
    try {
      final lowercaseQuery = query.toLowerCase();
      final expenses = expenseBox.values
          .where((expense) =>
              expense.title.toLowerCase().contains(lowercaseQuery) ||
              (expense.description?.toLowerCase().contains(lowercaseQuery) ?? false) ||
              expense.tags.any((tag) => tag.toLowerCase().contains(lowercaseQuery)))
          .toList();
      // Sort by creation date (newest first)
      expenses.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return expenses;
    } catch (e) {
      throw DatabaseFailure(message: "Failed to search expenses: ${e.toString()}");
    }
  }
}
