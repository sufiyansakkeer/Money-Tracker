import 'package:flutter/material.dart';
import 'package:money_track/Transaction/transaction_list.dart';
import 'package:money_track/db/category/db_category.dart';
import 'package:money_track/db/transaction/db_transaction_function.dart';
import 'package:money_track/models/categories_model/category_model.dart';
import 'package:money_track/models/transaction_model/transaction_model.dart';

class SearchTransaction extends SearchDelegate {
  @override
  ThemeData appBarTheme(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return theme;
  }

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back_ios_new),
      onPressed: () {
        close(context, null); // for closing the search page and going back
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    TransactionDB.instance.refreshUi();
    CategoryDb.instance.refreshUI();
    return ValueListenableBuilder(
      valueListenable: TransactionDB.instance.transactionListNotifier,
      builder:
          (BuildContext context, List<TransactionModel> newList, Widget? _) {
        return ListView.builder(
            itemBuilder: ((context, index) {
              final transaction = newList[index];
              if (transaction.categoryModel.categoryName
                  .toLowerCase()
                  .contains(query.toLowerCase())) {
                return Column(
                  children: [
                    ListTile(
                      title: Text(transaction.amount.toString()),
                      subtitle: Text(
                          transaction.categoryModel.categoryName.toString()),
                    ),
                  ],
                );
              } else {
                return Container();
              }
            }),
            itemCount: newList.length);
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    TransactionDB.instance.refreshUi();
    CategoryDb.instance.refreshUI();
    return ValueListenableBuilder(
      valueListenable: TransactionDB.instance.transactionListNotifier,
      builder:
          (BuildContext context, List<TransactionModel> newList, Widget? _) {
        return ListView.builder(
            itemBuilder: ((context, index) {
              final transaction = newList[index];
              if (transaction.categoryModel.categoryName
                  .toLowerCase()
                  .contains(query.toLowerCase())) {
                return Column(
                  children: [
                    ListTile(
                      leading: CircleAvatar(
                        child: Icon(
                          transaction.type == CategoryType.income
                              ? Icons.arrow_upward_outlined
                              : Icons.arrow_downward_outlined,
                          color: transaction.type == CategoryType.income
                              ? const Color(0xFF68AFF6)
                              : const Color(0xFFDE45FE),
                        ),
                      ),
                      title: Text(transaction.amount.toString()),
                      subtitle: Text(
                          transaction.categoryModel.categoryName.toString()),
                    ),
                  ],
                );
              } else {
                return Container();
              }
            }),
            itemCount: newList.length);
      },
    );
  }
}
