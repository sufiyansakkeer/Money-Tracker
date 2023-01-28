import 'package:flutter/material.dart';

import 'package:money_track/db/transaction/db_transaction_function.dart';
import 'package:money_track/models/categories_model/category_model.dart';
import 'package:money_track/models/transaction_model/transaction_model.dart';

ValueNotifier expenseTotal = ValueNotifier(0.0);
ValueNotifier incomeTotal = ValueNotifier(0.0);

ValueNotifier totalBalance = ValueNotifier(0.0);
void incomeAndExpense() {
  incomeTotal.value = 0;
  expenseTotal.value = 0;
  totalBalance.value = 0;
  final List<TransactionModel> value =
      TransactionDB.instance.transactionListNotifier.value;

  for (int i = 0; i < value.length; i++) {
    if (CategoryType.income == value[i].categoryModel.type) {
      incomeTotal.value = incomeTotal.value + value[i].amount;
    } else {
      expenseTotal.value = expenseTotal.value + value[i].amount;
    }
  }
  totalBalance.value = incomeTotal.value - expenseTotal.value;
}
