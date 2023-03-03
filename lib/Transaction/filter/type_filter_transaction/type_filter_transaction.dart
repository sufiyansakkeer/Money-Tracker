import 'package:flutter/material.dart';
import 'package:money_track/provider/transaction_provider.dart';
import 'package:money_track/transaction/view_all_transaction.dart';
import 'package:provider/provider.dart';

class TypeFilterClass extends StatelessWidget {
  const TypeFilterClass({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ProviderTransaction>(
        builder: (context, showCategory, child) {
      return PopupMenuButton(
          shape: ContinuousRectangleBorder(
            borderRadius: BorderRadius.circular(
              20,
            ),
          ),
          itemBuilder: ((context) => [
                PopupMenuItem(
                  value: 1,
                  onTap: () => showCategory.setShowCategory = "All",
                  child: const Text("All"),
                ),
                PopupMenuItem(
                  value: 2,
                  onTap: () => showCategory.setShowCategory = "Income",
                  child: const Text("Income"),
                ),
                PopupMenuItem(
                  value: 3,
                  onTap: () => showCategory.setShowCategory = "Expense",
                  child: const Text("Expense"),
                ),
              ]),
          child: const Icon(
            Icons.filter_list_rounded,
            size: 30,
            // shadows: <Shadow>[Shadow(color: Colors.white, blurRadius: 15.0)],
          ));
    });
  }
}
