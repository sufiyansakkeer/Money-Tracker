import 'package:flutter/material.dart';
import 'package:money_track/models/categories_model/category_model.dart';

class CategoryTypeProvider extends ChangeNotifier {
  TransactionType selectCategoryProvider = TransactionType.income;
  onChanging(value, newCategory) {
    if (value == null) {
      return;
    }
    if (selectCategoryProvider == TransactionType.income) {
      selectCategoryProvider = TransactionType.expense;

      notifyListeners();
    } else {
      selectCategoryProvider = TransactionType.income;
      notifyListeners();
    }
    selectCategoryProvider = newCategory;
    notifyListeners();
  }
}
