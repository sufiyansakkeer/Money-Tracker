import 'package:flutter/material.dart';
import 'package:money_track/db/transaction/db_transaction_function.dart';
import 'package:money_track/models/transaction_model/transaction_model.dart';

class SearchTransaction extends SearchDelegate {
  @override
  ThemeData appBarTheme(BuildContext context) {
    assert(context != null);
    final ThemeData theme = Theme.of(context);
    assert(theme != null);
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
    return ValueListenableBuilder(
      valueListenable: TransactionDB.instance.transactionListNotifier,
      builder:
          (BuildContext context, List<TransactionModel> newList, Widget? _) {
        return ListView.builder(
            itemBuilder: ((context, index) {
              final transaction = newList[index];
              if (transaction.notes
                  .toLowerCase()
                  .contains(query.toLowerCase())) {
                return Column(
                  children: [
                    ListTile(
                      title: Text(transaction.amount.toString()),
                      subtitle: Text(transaction.notes),
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
    return ValueListenableBuilder(
      valueListenable: TransactionDB.instance.transactionListNotifier,
      builder:
          (BuildContext context, List<TransactionModel> newList, Widget? _) {
        return ListView.builder(
            itemBuilder: ((context, index) {
              final transaction = newList[index];
              if (transaction.notes
                  .toLowerCase()
                  .contains(query.toLowerCase())) {
                return Column(
                  children: const [
                    ListTile(),
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
