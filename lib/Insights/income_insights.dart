import 'package:flutter/material.dart';
import 'package:money_track/Insights/over_view_graph.dart';
import 'package:money_track/constants/color/colors.dart';
import 'package:money_track/db/transaction/income_and_expense.dart';
import 'package:money_track/models/categories_model/category_model.dart';
import 'package:money_track/models/transaction_model/transaction_model.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class IncomeInsights extends StatelessWidget {
  const IncomeInsights({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: ValueListenableBuilder(
          valueListenable: overViewGraphNotifier,
          builder: (BuildContext context, List<TransactionModel> newList,
              Widget? child) {
            // Map incomeMap = {
            //   'name': 'Income',
            //   "amount": incomeTotal.value
            // };
            // Map expenseMap = {
            //   "name": "Expense",
            //   "amount": expenseTotal.value
            // };
            // List<Map> totalMap = [incomeMap, expenseMap];
            var allIncome = newList
                .where((element) => element.type == CategoryType.income)
                .toList();
            return SfCircularChart(
              // tooltipBehavior: _tooltipBehavior,
              series: <CircularSeries>[
                PieSeries<TransactionModel, String>(
                  dataSource: allIncome,
                  // color: themeDarkBlue,
                  // xAxisName: 'Category',
                  // yAxisName: 'Amount',
                  xValueMapper: (TransactionModel incomeDate, _) =>
                      incomeDate.categoryModel.categoryName,
                  yValueMapper: (TransactionModel incomeDate, _) =>
                      incomeDate.amount,
                  // enableTooltip: true,

                  // name: totalMap.toString(),
                  dataLabelSettings: const DataLabelSettings(
                    isVisible: true,
                    // borderWidth: 20,
                  ),
                  // markerSettings: const MarkerSettings(
                  //   isVisible: true,
                  // ),
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
