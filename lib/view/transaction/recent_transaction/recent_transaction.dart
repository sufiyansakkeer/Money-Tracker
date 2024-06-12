// import 'package:flutter/material.dart';
// import 'package:money_track/provider/transaction_provider.dart';
// import 'package:money_track/view/transaction/slidable/slidable_transaction.dart';

// import 'package:provider/provider.dart';

// class RecentTransactionList extends StatelessWidget {
//   const RecentTransactionList({super.key});

//   @override
//   Widget build(BuildContext context) {
//     // TransactionDB.instance.refreshUi();
//     context.read<ProviderTransaction>().refreshUi();
//     return Consumer<ProviderTransaction>(
//       builder: (context, newList, child) {
//         return newList.transactionListProvider.isEmpty
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
//             : ListView.builder(
//                 padding: const EdgeInsets.only(
//                   left: 15,
//                   right: 15,
//                 ),
//                 // separatorBuilder: ((context, index) {
//                 //   return const Divider();
//                 // }),
//                 itemCount: newList.transactionListProvider.length > 3
//                     ? 3
//                     : newList.transactionListProvider.length,
//                 itemBuilder: (context, index) {
//                   final transaction = newList.transactionListProvider[index];

//                   return Padding(
//                     padding: const EdgeInsets.symmetric(
//                       vertical: 5,
//                     ),
//                     child: SlidableTransaction(transaction: transaction),
//                   );
//                 });
//       },
//     );
//   }
// }
