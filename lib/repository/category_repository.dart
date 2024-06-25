import 'dart:developer';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:money_track/core/constants/db_constants.dart';
import 'package:money_track/helper/snack_bar_extension.dart';
import 'package:money_track/models/categories_model/category_model.dart';

class CategoryRepository {
  Future<void> setConstantCategoryModels() async {
    try {
      final categoryDB =
          await Hive.openBox<CategoryModel>(DBConstants.categoryDbName);
      if (categoryDB.values.toList().isEmpty) {
        for (var category in _categoryConstants) {
          log("category type $category adding",
              name: "Inside for loop of set Constants");
          await categoryDB.put(category.id, category);
        }
      }
    } catch (e) {
      log(e.toString(), name: "Exception while registering the categories");
    }
  }

  Future<String> addCategoryToDB(CategoryModel categoryModel) async {
    try {
      final categoryDB =
          await Hive.openBox<CategoryModel>(DBConstants.categoryDbName);
      categoryDB.add(
        categoryModel,
      );
      return "success";
    } catch (e) {
      log(e.toString(), name: "add Category Exception");
      "Unable to add Category".showSnack();
      return "error";
      // "Unable to add Category".sh
    }
  }

  Future<void> deleteCategory(String categoryID) async {
    final categoryDB =
        await Hive.openBox<CategoryModel>(DBConstants.categoryDbName);
    await categoryDB.delete(categoryID);
  }
}

List<CategoryModel> _categoryConstants = [
  CategoryModel(
    id: DateTime.fromMicrosecondsSinceEpoch(DateTime.now().microsecond)
        .toString(),
    categoryName: "Other",
    type: TransactionType.expense,
    categoryType: CategoryType.other,
  ),
  CategoryModel(
    id: DateTime.fromMicrosecondsSinceEpoch(DateTime.now().microsecond)
        .toString(),
    categoryName: "Salary",
    type: TransactionType.income,
    categoryType: CategoryType.salary,
  ),
  CategoryModel(
    id: DateTime.fromMicrosecondsSinceEpoch(DateTime.now().microsecond)
        .toString(),
    categoryName: "Food",
    type: TransactionType.expense,
    categoryType: CategoryType.food,
  ),
  CategoryModel(
    id: DateTime.fromMicrosecondsSinceEpoch(DateTime.now().microsecond)
        .toString(),
    categoryName: "Transportation",
    type: TransactionType.expense,
    categoryType: CategoryType.transportation,
  ),
  CategoryModel(
    id: DateTime.fromMicrosecondsSinceEpoch(DateTime.now().microsecond)
        .toString(),
    categoryName: "Subscription",
    type: TransactionType.expense,
    categoryType: CategoryType.subscription,
  ),
  CategoryModel(
    id: DateTime.fromMicrosecondsSinceEpoch(DateTime.now().microsecond)
        .toString(),
    categoryName: "Shopping",
    type: TransactionType.expense,
    categoryType: CategoryType.shopping,
  ),
];
