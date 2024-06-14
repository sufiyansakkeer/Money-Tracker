// import 'dart:developer';

// import 'package:flutter/material.dart';
// import 'package:lottie/lottie.dart';
// import 'package:money_track/provider/transaction_provider.dart';

// import 'package:money_track/models/categories_model/category_model.dart';

// import 'package:money_track/models/transaction_model/transaction_model.dart';
// import 'package:money_track/view/transaction/slidable/slidable_transaction.dart';
// import 'package:provider/provider.dart';

// class TransactionList extends StatelessWidget {
//   const TransactionList({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Consumer<ProviderTransaction>(
//         builder: (BuildContext context, newList, Widget? _) {
//       //here we building the list using displayList list
//       log("consumer is building");
//       var displayList = [];
//       //here if the showCategory notifier value is income (which will be changed based on the changes in popMenuItem )
//       if (newList.showCategory == "Income") {
//         //here i am creating an empty list for the transaction,
//         //so i can pick the income only through the where function
//         List<TransactionModel> incomeTransactionList = [];

//         incomeTransactionList = newList.overviewTransactions
//             .where((element) => element.type == CategoryType.income)
//             .toList();
//         //assigning the list into displayList which is the list i declared above
//         displayList = incomeTransactionList;
//       } else if (newList.showCategory == "Expense") {
//         List<TransactionModel> incomeTransactionList = [];
//         incomeTransactionList = newList.overviewTransactions
//             .where((element) => element.type == CategoryType.expense)
//             .toList();
//         displayList = incomeTransactionList;
//       } else {
//         displayList = newList.overviewTransactions;
//       }
//       //here i am checking whether the list is empty or not ,
//       //if it is empty i would sent a lottie to it
//       return displayList.isEmpty
//           ? SingleChildScrollView(
//               child: Center(
//                 child: Padding(
//                   padding: const EdgeInsets.all(50.0),
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.spaceAround,
//                     children: [
//                       Lottie.asset('assets/images/no-data.json'),
//                     ],
//                   ),
//                 ),
//               ),
//             )
//           : ListView.separated(
//               padding: const EdgeInsets.only(
//                 left: 15,
//                 right: 15,
//               ),
//               separatorBuilder: ((context, index) {
//                 return const Divider();
//               }),
//               itemCount: displayList.length,
//               itemBuilder: (context, index) {
//                 final transaction = displayList[index];
//                 log(transaction.toString());

//                 return SlidableTransaction(transaction: transaction);
//               });
//     });
//   }
// }
