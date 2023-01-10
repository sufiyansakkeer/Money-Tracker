import 'package:flutter/material.dart';
import 'package:money_track/categories/expence_transaction_list.dart';
import 'package:money_track/categories/income_transaction_list.dart';
import 'package:money_track/home/widgets/transaction_list.dart';

class TransactionCategories extends StatelessWidget {
  const TransactionCategories({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Transaction categories',
          ),
          bottom: TabBar(
            tabs: [
              Container(
                color: Colors.blue,
                child: Tab(
                  text: 'Income',
                ),
              ),
              Tab(
                text: 'Expense',
              ),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            IncomeTransaction(),
            ExpenseTransaction(),
          ],
          clipBehavior: Clip.antiAlias,
        ),
      ),
    );
  }
}
