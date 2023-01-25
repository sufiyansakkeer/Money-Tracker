import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:money_track/Transaction/transaction_list.dart';
import 'package:money_track/db/transaction/db_transaction_function.dart';

class SearchField extends StatelessWidget {
  const SearchField({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: TextField(
          onChanged: (value) => searchResult(value),
          decoration: const InputDecoration(
            hintText: 'Search..',
            border: OutlineInputBorder(),
          ),
        ),
      ),
    );
  }

  searchResult(String query) {
    if (query.isEmpty) {
      overViewListNotifier.value =
          TransactionDB.instance.transactionListNotifier.value;
    } else {
      overViewListNotifier.value = overViewListNotifier.value
          .where(
              (element) => element.categoryModel.categoryName.contains(query))
          .toList();
    }
  }
}
