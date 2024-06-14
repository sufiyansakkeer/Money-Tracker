// import 'package:flutter/material.dart';

// import 'package:money_track/provider/transaction_provider.dart';

// import 'package:money_track/models/categories_model/category_model.dart';
// import 'package:money_track/models/transaction_model/transaction_model.dart';
// import 'package:money_track/view/insights/widgets/no_data_found_women.dart';

// import 'package:provider/provider.dart';
// import 'package:syncfusion_flutter_charts/charts.dart';

// class ExpenseInsights extends StatefulWidget {
//   const ExpenseInsights({super.key});

//   @override
//   State<ExpenseInsights> createState() => _ExpenseInsightsState();
// }

// class _ExpenseInsightsState extends State<ExpenseInsights> {
//   @override
//   Widget build(BuildContext context) {
//     return SafeArea(
//       child: Scaffold(
//         body: Consumer<ProviderTransaction>(
//           builder: (context, value, child) {
//             var allIncome = value.overviewGraphTransactions
//                 .where((element) => element.type == CategoryType.expense)
//                 .toList();
//             return allIncome.isEmpty
//                 ? const NoDataFoundWomenWidget()
//                 : SfCircularChart(
//                     series: <CircularSeries>[
//                       PieSeries<TransactionModel, String>(
//                         dataSource: allIncome,
//                         xValueMapper: (TransactionModel expenseDate, _) =>
//                             expenseDate.categoryModel.categoryName,
//                         yValueMapper: (TransactionModel expenseDate, _) =>
//                             expenseDate.amount,
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
//                     // primaryXAxis: CategoryAxis(),
//                   );
//           },
//         ),
//       ),
//     );
//   }
// }
