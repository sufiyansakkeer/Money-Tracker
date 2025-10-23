import 'package:money_track/core/error/failures.dart';
import 'package:money_track/core/error/result.dart';
import 'package:money_track/features/groups/data/datasources/shared_expense_local_data_source.dart';
import 'package:money_track/features/groups/data/models/shared_expense_model.dart';
import 'package:money_track/features/groups/domain/entities/shared_expense_entity.dart';
import 'package:money_track/features/groups/domain/repositories/shared_expense_repository.dart';

class SharedExpenseRepositoryImpl implements SharedExpenseRepository {
  final SharedExpenseLocalDataSource localDataSource;

  SharedExpenseRepositoryImpl({
    required this.localDataSource,
  });

  @override
  Future<Result<List<SharedExpenseEntity>>> getSharedExpenses() async {
    try {
      final models = await localDataSource.getSharedExpenses();
      final entities = models.map((model) => model.toEntity()).toList();
      return Success(entities);
    } on DatabaseFailure catch (e) {
      return Error(e);
    } catch (e) {
      return Error(DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<List<SharedExpenseEntity>>> getSharedExpensesByGroup(
      String groupId) async {
    try {
      final models = await localDataSource.getSharedExpensesByGroup(groupId);
      final entities = models.map((model) => model.toEntity()).toList();
      return Success(entities);
    } on DatabaseFailure catch (e) {
      return Error(e);
    } catch (e) {
      return Error(DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<SharedExpenseEntity?>> getSharedExpenseById(
      String expenseId) async {
    try {
      final model = await localDataSource.getSharedExpenseById(expenseId);
      final entity = model?.toEntity();
      return Success(entity);
    } on DatabaseFailure catch (e) {
      return Error(e);
    } catch (e) {
      return Error(DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<void>> addSharedExpense(SharedExpenseEntity expense) async {
    try {
      final model = SharedExpenseModel.fromEntity(expense);
      await localDataSource.addSharedExpense(model);
      return const Success(null);
    } on DatabaseFailure catch (e) {
      return Error(e);
    } catch (e) {
      return Error(DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<void>> updateSharedExpense(SharedExpenseEntity expense) async {
    try {
      final model = SharedExpenseModel.fromEntity(expense);
      await localDataSource.updateSharedExpense(model);
      return Success(null);
    } on DatabaseFailure catch (e) {
      return Error(e);
    } catch (e) {
      return Error(DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<void>> deleteSharedExpense(String expenseId) async {
    try {
      await localDataSource.deleteSharedExpense(expenseId);
      return Success(null);
    } on DatabaseFailure catch (e) {
      return Error(e);
    } catch (e) {
      return Error(DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<List<SharedExpenseEntity>>> getSharedExpensesByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final models = await localDataSource.getSharedExpensesByDateRange(
          startDate, endDate);
      final entities = models.map((model) => model.toEntity()).toList();
      return Success(entities);
    } on DatabaseFailure catch (e) {
      return Error(e);
    } catch (e) {
      return Error(DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<List<SharedExpenseEntity>>> getSharedExpensesByCategory(
      String categoryId) async {
    try {
      final models =
          await localDataSource.getSharedExpensesByCategory(categoryId);
      final entities = models.map((model) => model.toEntity()).toList();
      return Success(entities);
    } on DatabaseFailure catch (e) {
      return Error(e);
    } catch (e) {
      return Error(DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<List<SharedExpenseEntity>>> searchSharedExpenses(
      String query) async {
    try {
      final models = await localDataSource.searchSharedExpenses(query);
      final entities = models.map((model) => model.toEntity()).toList();
      return Success(entities);
    } on DatabaseFailure catch (e) {
      return Error(e);
    } catch (e) {
      return Error(DatabaseFailure(message: e.toString()));
    }
  }
}
