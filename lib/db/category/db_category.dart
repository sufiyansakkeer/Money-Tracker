import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/adapters.dart';

import '../../models/categories_model/category_model.dart';

const categoryDBName = 'category-name';

abstract class CategoryDBFunction {
  Future<List<CategoryModel>> getAllCategory();
  Future<void> insertCategory(CategoryModel value);
  Future<void> deleteCategory(String categoryId);
}

class CategoryDB implements CategoryDBFunction {
  CategoryDB._internal();

  static CategoryDB instanse = CategoryDB._internal();

  factory CategoryDB() {
    return instanse;
  }

  ValueNotifier<List<CategoryModel>> incomeCategoryNotifierListener =
      ValueNotifier([]);
  ValueNotifier<List<CategoryModel>> expenseCategoryNotifierListener =
      ValueNotifier([]);

  @override
  Future<void> insertCategory(CategoryModel value) async {
    final categoryDB = await Hive.openBox<CategoryModel>(categoryDBName);
    await categoryDB.put(value.id, value);
    //here we added notify listener so then only the widget get updated ,
    // because notify listener will tell the widget to update
    incomeCategoryNotifierListener.notifyListeners();
    expenseCategoryNotifierListener.notifyListeners();
    refreshUI();
  }

  @override
  Future<List<CategoryModel>> getAllCategory() async {
    final categoryDB = await Hive.openBox<CategoryModel>(categoryDBName);
    incomeCategoryNotifierListener.notifyListeners();
    expenseCategoryNotifierListener.notifyListeners();
    //here we need to get all the data's ,it is in a list form thats why we convert it into list.
    return categoryDB.values.toList();
  }

  Future<void> refreshUI() async {
    final allCategories = await getAllCategory();
    //to clear the category before adding again , it will avoid duplication
    incomeCategoryNotifierListener.value.clear();
    expenseCategoryNotifierListener.value.clear();
    //here it will separate the category into income and expense
    await Future.forEach(allCategories, (CategoryModel category) {
      if (category.type == CategoryType.income) {
        incomeCategoryNotifierListener.value.add(category);
      } else {
        expenseCategoryNotifierListener.value.add(category);
      }
    });
  }

  @override
  Future<void> deleteCategory(String categoryId) async {
    final categoryDB = await Hive.openBox<CategoryModel>(categoryDBName);
    await categoryDB.delete(categoryId);
  }
}
