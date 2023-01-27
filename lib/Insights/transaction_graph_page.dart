import 'package:buttons_tabbar/buttons_tabbar.dart';
import 'package:flutter/material.dart';

import 'package:money_track/Insights/expense_insights.dart';
import 'package:money_track/Insights/income_insights.dart';
import 'package:money_track/Insights/over_view_graph.dart';
import 'package:money_track/constants/color/colors.dart';

class TransactionInsightsAll extends StatefulWidget {
  const TransactionInsightsAll({super.key});

  @override
  State<TransactionInsightsAll> createState() => _TransactionInsightsAllState();
}

class _TransactionInsightsAllState extends State<TransactionInsightsAll> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DefaultTabController(
        length: 3,
        child: Column(
          // mainAxisAlignment: mai,
          children: <Widget>[
            Container(
              alignment: Alignment.center,
              // transformAlignment: Alignment.center,
              decoration: BoxDecoration(
                  color: themeDarkBlue,
                  border: Border.all(width: 0, color: themeDarkBlue)),
              width: double.infinity,
              child: ButtonsTabBar(
                contentPadding: const EdgeInsets.symmetric(horizontal: 45),
                borderColor: const Color.fromARGB(255, 255, 98, 0),
                backgroundColor: Colors.white,
                unselectedBackgroundColor: Colors.grey,
                labelSpacing: 30,
                labelStyle: const TextStyle(
                  color: themeDarkBlue,
                ),
                unselectedLabelStyle: const TextStyle(color: themeDarkBlue),
                tabs: const [
                  Tab(
                    text: 'All',
                  ),
                  Tab(
                    iconMargin: EdgeInsets.all(30),
                    // icon: Icon(
                    //   Icons.arrow_circle_up_rounded,
                    //   color: incomeColor,
                    // ),
                    text: 'Income',
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
                    text: 'Expense',
                    // icon: Icon(
                    //   Icons.arrow_downward_outlined,
                    //   color: expenseColor,
                    // ),
                    // child: Padding(
                    //   padding: EdgeInsets.symmetric(horizontal: 40),
                    //   child: Text(
                    //     'Expense',
                    //     style: TextStyle(color: Colors.white),
                    //   ),
                    // ),
                  ),
                ],
              ),
            ),
            Expanded(
                child: TabBarView(children: [
              TransactionOverView(),
              IncomeInsights(),
              ExpenseInsights(),
            ]))
          ],
        ),
      ),
    );
  }
}
