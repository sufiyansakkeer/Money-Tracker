import 'package:flutter/material.dart';
import 'package:money_track/Transaction/view_all_transaction.dart';

class TypeFilterClass extends StatelessWidget {
  const TypeFilterClass({super.key});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton(
        itemBuilder: ((context) => [
              PopupMenuItem(
                value: 1,
                onTap: () => showCategory.value = "All",
                child: const Text("All"),
              ),
              PopupMenuItem(
                value: 2,
                onTap: () => showCategory.value = "Income",
                child: const Text("Income"),
              ),
              PopupMenuItem(
                value: 3,
                onTap: () => showCategory.value = "Expense",
                child: const Text("Expense"),
              ),
            ]));
  }
}
