import 'package:flutter/material.dart';

import 'package:money_track/Insights/over_view_graph.dart';
import 'package:money_track/models/categories_model/category_model.dart';
import 'package:money_track/models/transaction_model/transaction_model.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class ExpenseInsights extends StatefulWidget {
  const ExpenseInsights({super.key});

  @override
  State<ExpenseInsights> createState() => _ExpenseInsightsState();
}

class _ExpenseInsightsState extends State<ExpenseInsights> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: ValueListenableBuilder(
          valueListenable: overViewGraphNotifier,
          builder: (BuildContext context, List<TransactionModel> newList,
              Widget? child) {
            var allIncome = newList
                .where((element) => element.type == CategoryType.expense)
                .toList();
            return SfCircularChart(
              series: <CircularSeries>[
                PieSeries<TransactionModel, String>(
                  dataSource: allIncome,
                  xValueMapper: (TransactionModel expenseDate, _) =>
                      expenseDate.categoryModel.categoryName,
                  yValueMapper: (TransactionModel expenseDate, _) =>
                      expenseDate.amount,
                  dataLabelSettings: const DataLabelSettings(
                    isVisible: true,
                    // borderWidth: 20,
                  ),
                )
              ],
              legend: Legend(
                isVisible: true,
                overflowMode: LegendItemOverflowMode.scroll,
                alignment: ChartAlignment.center,
              ),
              // primaryXAxis: CategoryAxis(),
            );
          },
        ),
      ),
    );
  }
}
