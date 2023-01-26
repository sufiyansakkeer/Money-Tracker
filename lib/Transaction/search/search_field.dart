import 'package:flutter/material.dart';

import 'package:money_track/Transaction/transaction_list.dart';
import 'package:money_track/db/transaction/db_transaction_function.dart';

class SearchField extends StatelessWidget {
  SearchField({super.key});
  final TextEditingController _searchQueryController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Card(
        elevation: 9,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: TextField(
            controller: _searchQueryController,
            onChanged: (query) {
              searchResult(query);
              // overViewListNotifier.notifyListeners();
            },
            decoration: InputDecoration(
                hintText: 'Search..',
                border: InputBorder.none,
                icon: const Icon(
                  Icons.search,
                  // color: textClr,
                ),
                suffixIcon: IconButton(
                    onPressed: () {
                      overViewListNotifier.value =
                          TransactionDB.instance.transactionListNotifier.value;
                      _searchQueryController.clear();
                    },
                    icon: const Icon(
                      Icons.close,
                      // color: Colors.black,
                    ))),
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
