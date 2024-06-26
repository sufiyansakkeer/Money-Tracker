// import 'package:flutter/material.dart';
// import 'package:money_track/provider/transaction_provider.dart';

// import 'package:money_track/models/categories_model/category_model.dart';
// import 'package:money_track/models/transaction_model/transaction_model.dart';
// import 'package:money_track/view/insights/widgets/no_data_found_women.dart';

// import 'package:provider/provider.dart';
// import 'package:syncfusion_flutter_charts/charts.dart';

// class IncomeInsights extends StatelessWidget {
//   const IncomeInsights({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return SafeArea(
//       child: Scaffold(
//         body: Consumer<ProviderTransaction>(
//           builder: (context, value, child) {
//             var allIncome = value.overviewGraphTransactions
//                 .where((element) => element.type == CategoryType.income)
//                 .toList();
//             return value.overviewGraphTransactions.isEmpty
//                 ? const NoDataFoundWomenWidget()
//                 : SfCircularChart(
//                     series: <CircularSeries>[
//                       PieSeries<TransactionModel, String>(
//                         dataSource: allIncome,
//                         xValueMapper: (TransactionModel incomeDate, _) =>
//                             incomeDate.categoryModel.categoryName,
//                         yValueMapper: (TransactionModel incomeDate, _) =>
//                             incomeDate.amount,
//                         dataLabelSettings: const DataLabelSettings(
//                           isVisible: true,
//                         ),
//                       )
//                     ],
//                     legend: const Legend(
//                       isVisible: true,
//                       overflowMode: LegendItemOverflowMode.scroll,
//                       alignment: ChartAlignment.center,
//                     ),
//                   );
//           },
//         ),
//       ),
//     );
//   }
// }
