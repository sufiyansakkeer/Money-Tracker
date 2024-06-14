import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:money_track/models/categories_model/category_model.dart';

class AddTransactionProvider extends ChangeNotifier {
  CategoryModel? selectedCategoryModel;
  TransactionType? selectedCategoryType = TransactionType.income;
  DateTime selectedDateTime = DateTime.now();
  int value = 0;
  String? categoryId;

  incomeChoiceChip() {
    value = 0;
    selectedCategoryType = TransactionType.income;
    categoryId = null;
    notifyListeners();
  }

  expenseChoiceChip() {
    value = 1;
    selectedCategoryType = TransactionType.expense;
    categoryId = null;
    notifyListeners();
  }

  dateSelection(DateTime? selectedTempDate) {
    log('$selectedTempDate');
    if (selectedTempDate == null) {
      selectedDateTime = DateTime.now();
      notifyListeners();
    } else {
      selectedDateTime = selectedTempDate;
      notifyListeners();
    }
    notifyListeners();
  }
}
