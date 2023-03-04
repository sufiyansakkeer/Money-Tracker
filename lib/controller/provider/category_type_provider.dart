import 'package:flutter/material.dart';
import 'package:money_track/models/categories_model/category_model.dart';

class CategoryTypeProvider extends ChangeNotifier {
  CategoryType selectCategoryProvider = CategoryType.income;
  onChanging(value, newCategory) {
    if (value == null) {
      return;
    }
    newCategory.selectCategoryProvider = value;
    notifyListeners();
  }
}
