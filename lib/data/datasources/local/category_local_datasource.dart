import 'dart:developer';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:money_track/core/constants/db_constants.dart';
import 'package:money_track/core/error/failures.dart';
import 'package:money_track/data/models/category_model.dart';

abstract class CategoryLocalDataSource {
  /// Get all categories from local database
  Future<List<CategoryModel>> getAllCategories();

  /// Add a new category to local database
  Future<String> addCategory(CategoryModel category);

  /// Delete a category from local database
  Future<void> deleteCategory(String categoryId);

  /// Set default categories in local database
  Future<void> setDefaultCategories();
}

class CategoryLocalDataSourceImpl implements CategoryLocalDataSource {
  final HiveInterface hive;

  CategoryLocalDataSourceImpl({required this.hive});

  @override
  Future<List<CategoryModel>> getAllCategories() async {
    try {
      final categoryDB =
          await hive.openBox<CategoryModel>(DBConstants.categoryDbName);
      return categoryDB.values.toList().reversed.toList();
    } catch (e) {
      log(e.toString(), name: "Get all category Model Exception");
      throw DatabaseFailure(
          message: "Failed to get categories: ${e.toString()}");
    }
  }

  @override
  Future<String> addCategory(CategoryModel category) async {
    try {
      final categoryDB =
          await hive.openBox<CategoryModel>(DBConstants.categoryDbName);
      await categoryDB.add(category);
      return "success";
    } catch (e) {
      log(e.toString(), name: "Add Category Exception");
      throw DatabaseFailure(message: "Failed to add category: ${e.toString()}");
    }
  }

  @override
  Future<void> deleteCategory(String categoryId) async {
    try {
      final categoryDB =
          await hive.openBox<CategoryModel>(DBConstants.categoryDbName);
      await categoryDB.delete(categoryId);
    } catch (e) {
      log(e.toString(), name: "Category delete Exception");
      throw DatabaseFailure(
          message: "Failed to delete category: ${e.toString()}");
    }
  }

  @override
  Future<void> setDefaultCategories() async {
    try {
      final categoryDB =
          await hive.openBox<CategoryModel>(DBConstants.categoryDbName);
      if (categoryDB.values.toList().isEmpty) {
        for (var category in _categoryConstants) {
          log("category type $category adding",
              name: "Inside for loop of set Constants");
          await categoryDB.put(category.id, category);
        }
      }
    } catch (e) {
      log(e.toString(), name: "Exception while registering the categories");
      throw DatabaseFailure(
          message: "Failed to set default categories: ${e.toString()}");
    }
  }
}

// Generate unique IDs for default categories
String _generateUniqueId(int index) {
  return DateTime.now()
      .add(Duration(microseconds: index * 100))
      .microsecondsSinceEpoch
      .toString();
}

List<CategoryModel> _categoryConstants = [
  CategoryModel(
    id: _generateUniqueId(1),
    categoryName: "Other",
    type: TransactionType.expense,
    categoryType: CategoryType.other,
  ),
  CategoryModel(
    id: _generateUniqueId(2),
    categoryName: "Salary",
    type: TransactionType.income,
    categoryType: CategoryType.salary,
  ),
  CategoryModel(
    id: _generateUniqueId(3),
    categoryName: "Food",
    type: TransactionType.expense,
    categoryType: CategoryType.food,
  ),
  CategoryModel(
    id: _generateUniqueId(4),
    categoryName: "Transportation",
    type: TransactionType.expense,
    categoryType: CategoryType.transportation,
  ),
  CategoryModel(
    id: _generateUniqueId(5),
    categoryName: "Subscription",
    type: TransactionType.expense,
    categoryType: CategoryType.subscription,
  ),
  CategoryModel(
    id: _generateUniqueId(6),
    categoryName: "Shopping",
    type: TransactionType.expense,
    categoryType: CategoryType.shopping,
  ),
];
