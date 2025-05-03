import 'package:money_track/core/error/failures.dart';
import 'package:money_track/core/error/result.dart';
import 'package:money_track/data/datasources/local/category_local_datasource.dart';
import 'package:money_track/data/models/category_model.dart';
import 'package:money_track/domain/entities/category_entity.dart';
import 'package:money_track/domain/repositories/category_repository.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  final CategoryLocalDataSource localDataSource;

  CategoryRepositoryImpl({required this.localDataSource});

  @override
  Future<Result<List<CategoryEntity>>> getAllCategories() async {
    try {
      final categoryModels = await localDataSource.getAllCategories();
      final categories = categoryModels.map((model) => model.toEntity()).toList();
      return Success(categories);
    } catch (e) {
      return Error(DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<String>> addCategory(CategoryEntity category) async {
    try {
      final categoryModel = CategoryModel.fromEntity(category);
      final result = await localDataSource.addCategory(categoryModel);
      return Success(result);
    } catch (e) {
      return Error(DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<void>> deleteCategory(String categoryId) async {
    try {
      await localDataSource.deleteCategory(categoryId);
      return const Success(null);
    } catch (e) {
      return Error(DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<void>> setDefaultCategories() async {
    try {
      await localDataSource.setDefaultCategories();
      return const Success(null);
    } catch (e) {
      return Error(DatabaseFailure(message: e.toString()));
    }
  }
}
