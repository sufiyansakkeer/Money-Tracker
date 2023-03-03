import 'package:flutter/material.dart';
import 'package:money_track/models/categories_model/category_model.dart';
import 'package:money_track/models/transaction_model/transaction_model.dart';
import 'package:money_track/provider/transaction_provider.dart';
import 'package:provider/provider.dart';

class IncomeAndExpense extends ChangeNotifier {
  double incomeTotal = 0;
  double expenseTotal = 0;
  double totalBalance = 0;
  void incomeAndExpense(List<TransactionModel> listOfModal) {
    // incomeTotal = 0;
    // expenseTotal = 0;
    // totalBalance = 0;
    final List<TransactionModel> value = listOfModal;

    for (int i = 0; i < value.length; i++) {
      if (CategoryType.income == value[i].categoryModel.type) {
        incomeTotal = incomeTotal + value[i].amount;
      } else {
        expenseTotal = expenseTotal + value[i].amount;
      }
    }
    totalBalance = incomeTotal - expenseTotal;

    notifyListeners();
  }
}
