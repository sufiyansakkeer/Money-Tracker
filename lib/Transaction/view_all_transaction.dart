import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:money_track/Transaction/transaction_list.dart';
import 'package:money_track/search/search_widget.dart';

class TransactionListAll extends StatefulWidget {
  const TransactionListAll({super.key});

  @override
  State<TransactionListAll> createState() => _TransactionListAllState();
}

class _TransactionListAllState extends State<TransactionListAll> {
  double incomeTotal = 0;
  double expenseTotal = 0;
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
          IconButton(
            onPressed: (() {}),
            icon: const Icon(Icons.filter_list),
          ),
          IconButton(
            onPressed: (() {}),
            icon: const Icon(Icons.more_vert_outlined),
          ),
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
