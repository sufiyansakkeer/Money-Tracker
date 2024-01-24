import 'package:buttons_tabbar/buttons_tabbar.dart';
import 'package:flutter/material.dart';
import 'package:money_track/core/colors.dart';
import 'package:money_track/provider/transaction_provider.dart';

import 'package:money_track/view/insights/widgets/expense_insights.dart';
import 'package:money_track/view/insights/widgets/income_insights.dart';
import 'package:money_track/view/insights/widgets/over_view_graph.dart';

import 'package:provider/provider.dart';

class TransactionInsightsAll extends StatelessWidget {
  const TransactionInsightsAll({super.key});

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) =>
        context.read<ProviderTransaction>().overviewGraphTransactions =
            context.read<ProviderTransaction>().transactionListProvider);
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
                Consumer<ProviderTransaction>(builder: (context, value, child) {
                  return PopupMenuButton<int>(
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
                            value.dateFilterTitle,
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
                          value.setOverViewGraphTransactions =
                              value.transactionListProvider;
                          value.dateFilterTitle = "All";
                        },
                      ),
                      PopupMenuItem(
                        value: 2,
                        child: const Text(
                          "Today",
                        ),
                        onTap: () {
                          value.setOverViewGraphTransactions =
                              value.transactionListProvider;
                          value.setOverViewGraphTransactions = value
                              .overviewGraphTransactions
                              .where((element) =>
                                  element.date.day == DateTime.now().day &&
                                  element.date.month == DateTime.now().month &&
                                  element.date.year == DateTime.now().year)
                              .toList();

                          value.dateFilterTitle = "Today";
                        },
                      ),
                      PopupMenuItem(
                        value: 2,
                        child: const Text(
                          "Yesterday",
                        ),
                        onTap: () {
                          value.setOverViewGraphTransactions =
                              value.transactionListProvider;
                          value.setOverViewGraphTransactions = value
                              .overviewGraphTransactions
                              .where((element) =>
                                  element.date.day == DateTime.now().day - 1 &&
                                  element.date.month == DateTime.now().month &&
                                  element.date.year == DateTime.now().year)
                              .toList();

                          value.dateFilterTitle = "Yesterday";
                        },
                      ),
                      PopupMenuItem(
                        value: 2,
                        child: const Text(
                          "Month",
                        ),
                        onTap: () {
                          value.setOverViewGraphTransactions =
                              value.transactionListProvider;
                          value.setOverViewGraphTransactions = value
                              .overviewGraphTransactions
                              .where((element) =>
                                  element.date.month == DateTime.now().month &&
                                  element.date.year == DateTime.now().year)
                              .toList();

                          value.dateFilterTitle = "Month";
                        },
                      ),
                    ],
                  );
                }),
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
                      decoration:
                          BoxDecoration(color: ColorConstants.themeDarkBlue),
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 40),
                      tabs: const [
                        Tab(
                          iconMargin: EdgeInsets.all(30),
                          text: 'All',
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
                  Expanded(
                      child: TabBarView(children: [
                    TransactionOverView(),
                    const IncomeInsights(),
                    const ExpenseInsights(),
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
