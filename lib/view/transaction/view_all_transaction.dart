import 'package:flutter/material.dart';
import 'package:money_track/view/transaction/filter/date_filter/date_filter_transaction.dart';
import 'package:money_track/view/transaction/filter/type_filter_transaction/type_filter_transaction.dart';
import 'package:money_track/view/transaction/search/search_field.dart';
import 'package:money_track/view/transaction/transaction_list.dart';

// ValueNotifier showCategory = ValueNotifier('All');
// ValueNotifier showDateNotifier = ValueNotifier("All");

class TransactionListAll extends StatelessWidget {
  const TransactionListAll({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'All Transactions',
        ),
        actions: const [
          DAteFilterTransaction(),
          SizedBox(
            width: 10,
          ),
          TypeFilterClass(),
          SizedBox(
            width: 20,
          ),
        ],
      ),
      body: Column(
        children: [
          SearchField(),
          const Expanded(
            child: TransactionList(),
          ),
        ],
      ),
    );
  }
}
