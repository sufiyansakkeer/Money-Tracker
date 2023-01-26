import 'package:flutter/material.dart';
import 'package:money_track/Transaction/transaction_list.dart';
import 'package:money_track/constants/color/colors.dart';
import 'package:money_track/db/category/db_category.dart';
import 'package:money_track/db/transaction/db_transaction_function.dart';
import 'package:money_track/db/transaction/income_and_expense.dart';
import 'package:money_track/models/categories_model/category_model.dart';
import 'package:money_track/models/transaction_model/transaction_model.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

ValueNotifier<List<TransactionModel>> overViewGraphNotifier =
    ValueNotifier(TransactionDB.instance.transactionListNotifier.value);

class TransactionInsights extends StatefulWidget {
  const TransactionInsights({super.key});

  @override
  State<TransactionInsights> createState() => _TransactionInsightsState();
}

class _TransactionInsightsState extends State<TransactionInsights> {
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
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
              onPressed: () {},
              icon: Icon(
                Icons.filter,
                color: themeDarkBlue,
              )),
          actions: [
            IconButton(
                onPressed: () {},
                icon: Icon(
                  Icons.calendar_today,
                  color: themeDarkBlue,
                ))
          ],
        ),
        body: ValueListenableBuilder(
          valueListenable: overViewGraphNotifier,
          builder: (BuildContext context, List<TransactionModel> newList,
              Widget? child) {
            Map incomeMap = {'name': 'Income', 'amount': incomeTotal.value};
            Map expenseMap = {'name': 'Income', 'amount': expenseTotal.value};
            List<Map> totalMap = [incomeMap, expenseMap];
            // var allIncome = newList
            //     .where((element) => element.type == CategoryType.income)
            //     .toList();
            return SfCartesianChart(
              legend: Legend(
                  isVisible: true,
                  overflowMode: LegendItemOverflowMode.scroll,
                  alignment: ChartAlignment.center),
              tooltipBehavior: _tooltipBehavior,
              series: <ChartSeries>[
                StackedColumnSeries<Map, String>(
                    dataSource: totalMap,
                    xValueMapper: (Map data, _) => data['name'],
                    yValueMapper: (Map data, _) => data['amount'],
                    enableTooltip: true,
                    dataLabelSettings: const DataLabelSettings(isVisible: true),
                    markerSettings: MarkerSettings(isVisible: true))
              ],
              primaryXAxis: CategoryAxis(),
            );
          },
        ),
      ),
    );
  }
}
