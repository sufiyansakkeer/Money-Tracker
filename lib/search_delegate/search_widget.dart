import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:money_track/Transaction/edit_transaction/edit_transaction.dart';
import 'package:money_track/Transaction/slidable/slidable_transaction.dart';

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
        List<TransactionModel> transaction = [];
        transaction = newList
            .where((element) => element.categoryModel.categoryName
                .toLowerCase()
                .contains(query.toLowerCase()))
            .toList();
        return transaction.isEmpty
            ? const Center(child: Text('no data found'))
            : ListView.builder(
                itemBuilder: ((context, index) {
                  return SlidableTransaction(transaction: transaction[index]);
                }),
                itemCount: transaction.length,
              );
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
        List<TransactionModel> transaction = [];
        transaction = newList
            .where((element) => element.categoryModel.categoryName
                .toLowerCase()
                .contains(query.toLowerCase()))
            .toList();
        return transaction.isEmpty
            ? Text('no data found')
            : ListView.builder(
                itemBuilder: ((context, index) {
                  return SlidableTransaction(transaction: transaction[index]);
                }),
                itemCount: transaction.length,
              );
      },
    );
  }
}
