// import 'package:flutter/material.dart';

// import 'package:money_track/Transaction/slidable/slidable_transaction.dart';
// import 'package:money_track/db/transaction/db_transaction_function.dart';
// import 'package:money_track/models/transaction_model/transaction_model.dart';

// class RecentTransactionList extends StatelessWidget {
//   const RecentTransactionList({super.key});

//   @override
//   Widget build(BuildContext context) {
//     TransactionDB.instance.refreshUi();
//     return ValueListenableBuilder(
//       valueListenable: TransactionDB.instance.transactionListNotifier,
//       builder:
//           (BuildContext context, List<TransactionModel> newList, Widget? _) {
//         return newList.isEmpty
//             ? Center(
//                 child: Padding(
//                   padding: const EdgeInsets.all(50.0),
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.spaceAround,
//                     children: [
//                       Image.asset(
//                         "assets/images/man-waiving-hand.gif",
//                         height: 150,
//                       ),
//                       const Text(
//                         'No Transaction Found',
//                         style: TextStyle(
//                           fontSize: 15,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               )
//             : ListView.separated(
//                 padding: const EdgeInsets.only(
//                   left: 15,
//                   right: 15,
//                 ),
//                 separatorBuilder: ((context, index) {
//                   return const Divider();
//                 }),
//                 itemCount: newList.length > 3 ? 3 : newList.length,
//                 itemBuilder: (context, index) {
//                   final transaction = newList[index];

//                   return SlidableTransaction(transaction: transaction);
//                 });
//       },
//     );
//   }
// }
