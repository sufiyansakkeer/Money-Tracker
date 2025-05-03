import 'package:money_track/core/error/result.dart';
import 'package:money_track/domain/entities/category_entity.dart';

/// Repository interface for category operations
abstract class CategoryRepository {
  /// Get all categories
  Future<Result<List<CategoryEntity>>> getAllCategories();
  
  /// Add a new category
  Future<Result<String>> addCategory(CategoryEntity category);
  
  /// Delete a category
  Future<Result<void>> deleteCategory(String categoryId);
  
  /// Set default categories
  Future<Result<void>> setDefaultCategories();
}
