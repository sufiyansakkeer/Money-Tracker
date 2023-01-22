import 'package:flutter/material.dart';

import 'package:money_track/Transaction/filter/date_filter/date_filter_transaction.dart';

import 'package:money_track/Transaction/transaction_list.dart';
import 'package:money_track/Transaction/filter/type_filter_transaction/type_filter_transaction.dart';

import 'package:money_track/search/search_widget.dart';

ValueNotifier showCategory = ValueNotifier('All');
ValueNotifier showDateNotifier = ValueNotifier("All");

class TransactionListAll extends StatefulWidget {
  const TransactionListAll({super.key});

  @override
  State<TransactionListAll> createState() => _TransactionListAllState();
}

class _TransactionListAllState extends State<TransactionListAll> {
  double expenseTotal = 0;
  double incomeTotal = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'All Transactions',
        ),
        actions: [
          IconButton(
            onPressed: (() {
              showSearch(
                context: context,
                delegate: SearchTransaction(),
              );
            }),
            icon: const Icon(Icons.search),
          ),
          const DAteFilterTransaction(),
          const TypeFilterClass(),
        ],
      ),
      body: Column(
        children: const [
          Expanded(
            child: SizedBox(
              width: double.infinity,
              child: TransactionList(),
            ),
          ),
        ],
      ),
    );
  }
}
