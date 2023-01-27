import 'package:flutter/material.dart';

import 'package:money_track/constants/color/colors.dart';

import 'package:money_track/db/transaction/db_transaction_function.dart';
import 'package:money_track/db/transaction/income_and_expense.dart';

import 'package:money_track/models/transaction_model/transaction_model.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

ValueNotifier<List<TransactionModel>> overViewGraphNotifier =
    ValueNotifier(TransactionDB.instance.transactionListNotifier.value);

class TransactionOverView extends StatefulWidget {
  const TransactionOverView({super.key});

  @override
  State<TransactionOverView> createState() => _TransactionOverView();
}

class _TransactionOverView extends State<TransactionOverView> {
  late TooltipBehavior _tooltipBehavior;

  @override
  void initState() {
    _tooltipBehavior = TooltipBehavior(enable: true);
    super.initState();
  }

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
                  Map incomeMap = {
                    'name': 'Income',
                    "amount": incomeTotal.value
                  };
                  Map expenseMap = {
                    "name": "Expense",
                    "amount": expenseTotal.value
                  };
                  List<Map> totalMap = [incomeMap, expenseMap];
                  // var allIncome = newList
                  //     .where((element) => element.type == CategoryType.income)
                  //     .toList();
                  return SfCircularChart(
                    tooltipBehavior: _tooltipBehavior,
                    series: <CircularSeries>[
                      PieSeries<Map, String>(
                        dataSource: totalMap,
                        // color: themeDarkBlue,
                        // xAxisName: 'Category',
                        // yAxisName: 'Amount',
                        xValueMapper: (Map data, _) => data['name'],
                        yValueMapper: (Map data, _) => data['amount'],
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
          ],
        ),
      ),
    );
  }
}
