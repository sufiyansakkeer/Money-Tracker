import 'package:flutter/material.dart';

import 'package:money_track/Transaction/slidable/slidable_transaction.dart';
import 'package:money_track/Transaction/view_all_transaction.dart';
import 'package:money_track/db/category/db_category.dart';

import 'package:money_track/db/transaction/db_transaction_function.dart';
import 'package:money_track/models/categories_model/category_model.dart';

import 'package:money_track/models/transaction_model/transaction_model.dart';

class TransactionList extends StatelessWidget {
  const TransactionList({super.key});

  @override
  Widget build(BuildContext context) {
    TransactionDB.instance.refreshUi();
    return ValueListenableBuilder(
      valueListenable: TransactionDB.instance.transactionListNotifier,
      builder:
          (BuildContext context, List<TransactionModel> newList, Widget? _) {
        return ValueListenableBuilder(
            valueListenable: showCategory,
            builder: (context, showCategoryList, child) {
              var displayList = [];
              if (showCategory.value == "Income") {
                List<TransactionModel> incomeTransactionList = [];
                incomeTransactionList = newList
                    .where((element) => element.type == CategoryType.income)
                    .toList();
                displayList = incomeTransactionList;
              } else if (showCategory.value == "Expense") {
                List<TransactionModel> expenseTransactionList = [];
                expenseTransactionList = newList
                    .where((element) => element.type == CategoryType.expense)
                    .toList();
                displayList = expenseTransactionList;
              } else {
                displayList = newList;
              }
              return displayList.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(50.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Image.asset(
                              "assets/images/man-waiving-hand.gif",
                              height: 150,
                            ),
                            const Text(
                              'No Transaction Found',
                              style: TextStyle(
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.only(
                        left: 15,
                        right: 15,
                      ),
                      separatorBuilder: ((context, index) {
                        return const Divider();
                      }),
                      itemCount: displayList.length,
                      itemBuilder: (context, index) {
                        final transaction = displayList[index];

                        return SlidableTransaction(transaction: transaction);
                      });
            });
      },
    );
  }
}
