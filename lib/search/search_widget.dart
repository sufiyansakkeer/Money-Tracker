import 'package:flutter/material.dart';

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
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.adaptive.arrow_back),
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
                      leading: CircleAvatar(
                        backgroundColor: Colors.transparent,
                        child: Icon(
                          transaction.type == CategoryType.income
                              ? Icons.arrow_upward_outlined
                              : Icons.arrow_downward_outlined,
                          color: transaction.type == CategoryType.income
                              ? const Color(0xFF68AFF6)
                              : const Color(0xFFDE45FE),
                        ),
                      ),
                      title: Text(
                        transaction.amount.toString(),
                        style: const TextStyle(color: Colors.black),
                      ),
                      subtitle: Text(
                          transaction.categoryModel.categoryName.toString()),
                    ),
                  ],
                );
              } else {
                return const Center(
                  child: Text(
                    'No data found',
                  ),
                );
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

              return transaction.categoryModel.categoryName
                      .toLowerCase()
                      .contains(query.toLowerCase())
                  ? Column(
                      children: [
                        Card(
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.transparent,
                              child: Icon(
                                transaction.type == CategoryType.income
                                    ? Icons.arrow_upward_outlined
                                    : Icons.arrow_downward_outlined,
                                color: transaction.type == CategoryType.income
                                    ? const Color(0xFF68AFF6)
                                    : const Color(0xFFDE45FE),
                              ),
                            ),
                            title: Text(
                              transaction.amount.toString(),
                              style: const TextStyle(color: Colors.black),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  transaction.categoryModel.categoryName
                                      .toString(),
                                ),
                                // Text(
                                //   transaction.notes.toString(),
                                // ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    )
                  : const Center(
                      child: Text(
                        'No data found',
                      ),
                    );
            }),
            itemCount: newList.length);
      },
    );
  }
}
