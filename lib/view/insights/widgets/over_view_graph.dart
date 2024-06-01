import 'package:flutter/material.dart';
import 'package:money_track/provider/transaction_provider.dart';
import 'package:money_track/view/insights/widgets/no_data_found_women.dart';

import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

// ValueNotifier<List<TransactionModel>> overViewGraphNotifier =
//     ValueNotifier(TransactionDB.instance.transactionListNotifier.value);

class TransactionOverView extends StatelessWidget {
  TransactionOverView({super.key});

  final TooltipBehavior _tooltipBehavior = TooltipBehavior(enable: true);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Consumer<ProviderTransaction>(
          builder: (context, value, child) {
            Map incomeMap = {'name': 'Income', "amount": value.incomeTotal};
            Map expenseMap = {"name": "Expense", "amount": value.expenseTotal};
            List<Map> totalMap = [incomeMap, expenseMap];
            return value.overviewGraphTransactions.isEmpty
                ? const NoDataFoundWomenWidget()
                : SfCircularChart(
                    tooltipBehavior: _tooltipBehavior,
                    series: <CircularSeries>[
                      PieSeries<Map, String>(
                        dataSource: totalMap,
                        xValueMapper: (Map data, _) => data['name'],
                        yValueMapper: (Map data, _) => data['amount'],
                        dataLabelSettings: const DataLabelSettings(
                          isVisible: true,
                        ),
                      )
                    ],
                    legend: const Legend(
                      isVisible: true,
                      overflowMode: LegendItemOverflowMode.scroll,
                      alignment: ChartAlignment.center,
                    ),
                  );
          },
        ),
      ),
    );
  }
}
