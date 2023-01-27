import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:money_track/Insights/over_view_graph.dart';
import 'package:money_track/constants/color/colors.dart';
import 'package:money_track/models/categories_model/category_model.dart';
import 'package:money_track/models/transaction_model/transaction_model.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class ExpenseInsights extends StatelessWidget {
  const ExpenseInsights({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: () {},
                  icon: const Icon(
                    Icons.filter,
                    color: themeDarkBlue,
                  ),
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(
                    Icons.calendar_today,
                    color: themeDarkBlue,
                  ),
                ),
              ],
            ),
            Expanded(
              child: ValueListenableBuilder(
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
          ],
        ),
      ),
    );
  }
}
