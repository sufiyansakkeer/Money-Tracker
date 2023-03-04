import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:money_track/controller/provider/transaction_provider.dart';

import 'package:provider/provider.dart';

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
              searchResult(query, context);
              log(query);
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
                      _searchQueryController.clear();
                      context.read<ProviderTransaction>().overviewTransactions =
                          context
                              .read<ProviderTransaction>()
                              .transactionListProvider;
                      context.read<ProviderTransaction>().notifyListeners();
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

  searchResult(String query, BuildContext context) {
    if (query.isEmpty) {
      context.read<ProviderTransaction>().overviewTransactions =
          context.read<ProviderTransaction>().transactionListProvider;
      context.read<ProviderTransaction>().notifyListeners();
    } else {
      context.read<ProviderTransaction>().overviewTransactions = context
          .read<ProviderTransaction>()
          .overviewTransactions
          .where((element) =>
              element.categoryModel.categoryName.toLowerCase().contains(query))
          .toList();
      log("${context.read<ProviderTransaction>().overviewTransactions}");
      context.read<ProviderTransaction>().notifyListeners();
    }
  }
}
