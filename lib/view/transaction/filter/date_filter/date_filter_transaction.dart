import 'package:flutter/material.dart';
import 'package:money_track/controller/provider/transaction_provider.dart';

import 'package:provider/provider.dart';

class DAteFilterTransaction extends StatelessWidget {
  const DAteFilterTransaction({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ProviderTransaction>(
        builder: (context, showCategory, child) {
      return PopupMenuButton<int>(
        shape: ContinuousRectangleBorder(
          borderRadius: BorderRadius.circular(
            20,
          ),
        ),
        child: const Icon(
          Icons.calendar_today_rounded,
          // size: 0,
          // shadows: <Shadow>[Shadow(color: Colors.white, blurRadius: 15.0)],
        ),
        itemBuilder: (ctx) => [
          PopupMenuItem(
            value: 1,
            child: const Text(
              "All",
            ),
            onTap: () {
              showCategory.setOverviewTransactions =
                  showCategory.transactionListProvider;
            },
          ),
          PopupMenuItem(
            value: 2,
            child: const Text(
              "Today",
            ),
            onTap: () {
              showCategory.setOverviewTransactions =
                  showCategory.transactionListProvider;
              showCategory.setOverviewTransactions = showCategory
                  .overviewTransactions
                  .where((element) =>
                      element.date.day == DateTime.now().day &&
                      element.date.month == DateTime.now().month &&
                      element.date.year == DateTime.now().year)
                  .toList();
            },
          ),
          PopupMenuItem(
              value: 2,
              child: const Text(
                "Yesterday",
              ),
              onTap: () {
                showCategory.setOverviewTransactions =
                    showCategory.transactionListProvider;
                showCategory.setOverviewTransactions = showCategory
                    .overviewTransactions
                    .where((element) =>
                        element.date.day == DateTime.now().day - 1 &&
                        element.date.month == DateTime.now().month &&
                        element.date.year == DateTime.now().year)
                    .toList();
              }),
          PopupMenuItem(
              value: 2,
              child: const Text(
                "Month",
              ),
              onTap: () {
                showCategory.setOverviewTransactions =
                    showCategory.transactionListProvider;
                showCategory.setOverviewTransactions = showCategory
                    .overviewTransactions
                    .where((element) =>
                        element.date.month == DateTime.now().month &&
                        element.date.year == DateTime.now().year)
                    .toList();
              }),
        ],
      );
    });
  }
}
