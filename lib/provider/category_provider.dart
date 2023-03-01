import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:money_track/models/categories_model/category_model.dart';

const categoryDbName = 'category-database';

class CategoryProvider extends ChangeNotifier {
  List<CategoryModel> incomeCategoryProvider = [];
  List<CategoryModel> expenseCategoryProvider = [];

  Future<void> insertCategory(CategoryModel value) async {
    final categoryDB = await Hive.openBox<CategoryModel>(categoryDbName);
    await categoryDB.put(value.id, value);
    refreshUI();
  }

  Future<List<CategoryModel>> getCategories() async {
    final categoryDB = await Hive.openBox<CategoryModel>(categoryDbName);
    return categoryDB.values.toList().reversed.toList();
  }

  Future<void> deleteCategory(String categoryID) async {
    final categoryDB = await Hive.openBox<CategoryModel>(categoryDbName);
    await categoryDB.delete(categoryID);
    refreshUI();
  }

  Future<void> refreshUI() async {
    final allCategories = await getCategories();
    incomeCategoryProvider.clear();
    expenseCategoryProvider.clear();
    await Future.forEach(
      allCategories,
      (CategoryModel category) {
        if (category.type == CategoryType.income) {
          incomeCategoryProvider.add(category);
        } else {
          expenseCategoryProvider.add(category);
        }
      },
    );
    notifyListeners();
  }
}
