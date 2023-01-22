import 'package:flutter/material.dart';
import 'package:money_track/Transaction/transaction_list.dart';
import 'package:money_track/db/transaction/db_transaction_function.dart';

class DAteFilterTransaction extends StatelessWidget {
  const DAteFilterTransaction({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<int>(
      shape: ContinuousRectangleBorder(
        borderRadius: BorderRadius.circular(
          20,
        ),
      ),
      child: const Icon(
        Icons.filter_list_rounded,
        size: 30,
        // shadows: <Shadow>[Shadow(color: Colors.white, blurRadius: 15.0)],
      ),
      itemBuilder: (ctx) => [
        PopupMenuItem(
          value: 1,
          child: const Text(
            "All",
          ),
          onTap: () {
            overViewListNotifier.value =
                TransactionDB.instance.transactionListNotifier.value;
          },
        ),
        PopupMenuItem(
          value: 2,
          child: const Text(
            "Today",
          ),
          onTap: () {
            overViewListNotifier.value =
                TransactionDB.instance.transactionListNotifier.value;
            overViewListNotifier.value = overViewListNotifier.value
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
              overViewListNotifier.value =
                  TransactionDB.instance.transactionListNotifier.value;
              overViewListNotifier.value = overViewListNotifier.value
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
              overViewListNotifier.value =
                  TransactionDB.instance.transactionListNotifier.value;
              overViewListNotifier.value = overViewListNotifier.value
                  .where((element) =>
                      element.date.month == DateTime.now().month &&
                      element.date.year == DateTime.now().year)
                  .toList();
            }),
      ],
    );
  }
}
