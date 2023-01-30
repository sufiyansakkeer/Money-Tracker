import 'package:buttons_tabbar/buttons_tabbar.dart';
import 'package:flutter/material.dart';

import 'package:money_track/Insights/expense_insights.dart';
import 'package:money_track/Insights/income_insights.dart';
import 'package:money_track/Insights/over_view_graph.dart';
import 'package:money_track/categories/expense_category.dart';
import 'package:money_track/constants/color/colors.dart';
import 'package:money_track/db/transaction/db_transaction_function.dart';

class TransactionInsightsAll extends StatefulWidget {
  const TransactionInsightsAll({super.key});

  @override
  State<TransactionInsightsAll> createState() => _TransactionInsightsAllState();
}

class _TransactionInsightsAllState extends State<TransactionInsightsAll> {
  String dateFilterTitle = "All";
  @override
  void initState() {
    super.initState();
    overViewGraphNotifier.value =
        TransactionDB.instance.transactionListNotifier.value;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                const Text(
                  'Date  ',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                PopupMenuButton<int>(
                  shape: ContinuousRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      50,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(
                      right: 15.0,
                    ),
                    child: Row(
                      children: [
                        Text(
                          dateFilterTitle,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Icon(
                          Icons.arrow_drop_down,
                          size: 30,
                        ),
                      ],
                    ),
                  ),
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 1,
                      child: const Text(
                        "All",
                      ),
                      onTap: () {
                        overViewGraphNotifier.value = TransactionDB
                            .instance.transactionListNotifier.value;
                        setState(() {
                          dateFilterTitle = "All";
                        });
                      },
                    ),
                    PopupMenuItem(
                      value: 2,
                      child: const Text(
                        "Today",
                      ),
                      onTap: () {
                        overViewGraphNotifier.value = TransactionDB
                            .instance.transactionListNotifier.value;
                        overViewGraphNotifier.value = overViewGraphNotifier
                            .value
                            .where((element) =>
                                element.date.day == DateTime.now().day &&
                                element.date.month == DateTime.now().month &&
                                element.date.year == DateTime.now().year)
                            .toList();
                        setState(() {
                          dateFilterTitle = "Today";
                        });
                      },
                    ),
                    PopupMenuItem(
                      value: 2,
                      child: const Text(
                        "Yesterday",
                      ),
                      onTap: () {
                        overViewGraphNotifier.value = TransactionDB
                            .instance.transactionListNotifier.value;
                        overViewGraphNotifier.value = overViewGraphNotifier
                            .value
                            .where((element) =>
                                element.date.day == DateTime.now().day - 1 &&
                                element.date.month == DateTime.now().month &&
                                element.date.year == DateTime.now().year)
                            .toList();
                        setState(() {
                          dateFilterTitle = "Yesterday";
                        });
                      },
                    ),
                    PopupMenuItem(
                      value: 2,
                      child: const Text(
                        "Month",
                      ),
                      onTap: () {
                        overViewGraphNotifier.value = TransactionDB
                            .instance.transactionListNotifier.value;

                        overViewGraphNotifier.value = overViewGraphNotifier
                            .value
                            .where((element) =>
                                element.date.month == DateTime.now().month &&
                                element.date.year == DateTime.now().year)
                            .toList();
                        setState(() {
                          dateFilterTitle = "Month";
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: DefaultTabController(
              length: 3,
              initialIndex: 0,
              child: Column(
                children: <Widget>[
                  Container(
                    alignment: Alignment.center,
                    // transformAlignment: Alignment.center,

                    width: double.infinity,
                    child: ButtonsTabBar(
                      tabs: const [
                        Tab(
                          iconMargin: EdgeInsets.all(30),
                          // icon: Icon(
                          //   Icons.arrow_circle_up_rounded,
                          //   color: incomeColor,
                          // ),
                          text: 'All',
                          // child: Padding(
                          //   padding: EdgeInsets.symmetric(horizontal: 40),
                          //   child: Text(
                          //     'Income',
                          //     style: TextStyle(
                          //       color: Colors.white,
                          //     ),
                          //   ),
                          // ),
                        ),
                        Tab(
                          text: 'Income',
                        ),
                        Tab(
                          text: 'Expense',
                        ),
                      ],
                    ),
                  ),
                  const Expanded(
                      child: TabBarView(children: [
                    TransactionOverView(),
                    IncomeInsights(),
                    ExpenseInsights(),
                  ]))
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
