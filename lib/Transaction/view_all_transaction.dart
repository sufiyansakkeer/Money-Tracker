import 'package:flutter/material.dart';

import 'package:money_track/Transaction/filter/date_filter/date_filter_transaction.dart';
import 'package:money_track/Transaction/search/search_field.dart';

import 'package:money_track/Transaction/transaction_list.dart';
import 'package:money_track/Transaction/filter/type_filter_transaction/type_filter_transaction.dart';
import 'package:money_track/db/transaction/db_transaction_function.dart';

import 'package:money_track/search_delegate/search_widget.dart';

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
  void initState() {
    overViewListNotifier.value =
        TransactionDB.instance.transactionListNotifier.value;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'All Transactions',
        ),
        actions: const [
          // IconButton(
          //   onPressed: (() {
          //     showSearch(
          //       context: context,
          //       delegate: SearchTransaction(),
          //     );
          //   }),
          //   icon: const Icon(Icons.search),
          // ),

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
          Expanded(
            child: TransactionList(),
          ),
        ],
      ),
    );
  }
}
