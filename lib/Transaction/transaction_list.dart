import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import 'package:money_track/Transaction/slidable/slidable_transaction.dart';
import 'package:money_track/Transaction/view_all_transaction.dart';

import 'package:money_track/db/transaction/db_transaction_function.dart';
import 'package:money_track/models/categories_model/category_model.dart';

import 'package:money_track/models/transaction_model/transaction_model.dart';

ValueNotifier<List<TransactionModel>> overViewListNotifier =
    ValueNotifier(TransactionDB.instance.transactionListNotifier.value);

class TransactionList extends StatelessWidget {
  const TransactionList({super.key});

  @override
  Widget build(BuildContext context) {
    TransactionDB.instance.refreshUi();
    return ValueListenableBuilder(
      //here transaction list notifier used to notify the db transaction actions
      //,according to the date .,overview List notifier is used for the date filter
      valueListenable: overViewListNotifier,
      builder: (BuildContext context, newList, Widget? _) {
        //we need to filter the transaction according to the transaction type ,
        //so i added a value notifier for the category type called "showCategory" ,
        return ValueListenableBuilder(
            valueListenable: showCategory,
            builder: (context, showCategoryList, child) {
              //here we building the list using displayList list
              var displayList = [];
              //here if the showCategory notifier value is income (which will be changed based on the changes in popMenuItem )
              if (showCategory.value == "Income") {
                //here i am creating an empty list for the transaction,
                //so i can pick the income only through the where function
                List<TransactionModel> incomeTransactionList = [];
                //here i converting the element into list using toList function
                incomeTransactionList = newList
                    .where((element) => element.type == CategoryType.income)
                    .toList();
                //assigning the list into displayList which is the list i declared above
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
              //here i am checking whether the list is empty or not ,
              //if it is empty i would sent a lottie to it
              return displayList.isEmpty
                  ? SingleChildScrollView(
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(50.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Lottie.asset('assets/images/no-data.json'),
                            ],
                          ),
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
