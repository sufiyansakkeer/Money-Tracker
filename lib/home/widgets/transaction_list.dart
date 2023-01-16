import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:money_track/db/transaction/db_transaction_function.dart';
import 'package:money_track/models/categories_model/category_model.dart';
import 'package:money_track/models/transaction_model/transaction_model.dart';

class TransactionListAll extends StatefulWidget {
  const TransactionListAll({super.key});

  @override
  State<TransactionListAll> createState() => _TransactionListAllState();
}

class _TransactionListAllState extends State<TransactionListAll> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            SliverAppBar(
              leading: IconButton(
                  onPressed: (() {
                    Navigator.of(context).pop();
                  }),
                  icon: const Icon(
                    Icons.arrow_back_ios_new,
                    color: Color(0xFF2E49FB),
                  )),
              backgroundColor: Colors.transparent,
              actions: [
                IconButton(
                  onPressed: (() {}),
                  icon: const Icon(
                    Icons.search,
                    color: Color(0xFF2E49FB),
                  ),
                ),
              ],
              expandedHeight: 200.0,
              floating: false,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                centerTitle: true,
                title: const Text(
                  "Transactions",
                  style: TextStyle(
                      color: Color(0xFF2E49FB),
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold),
                ),
                background: Image.asset(
                  "assets/images/lf30_editor_bwrnwosd.gif",
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ];
        },
        body: const TransactionList(),
      ),
    );
  }
}

class TransactionList extends StatefulWidget {
  const TransactionList({super.key});

  @override
  State<TransactionList> createState() => _TransactionListState();
}

class _TransactionListState extends State<TransactionList> {
  @override
  Widget build(BuildContext context) {
    TransactionDB.instance.refreshUi();
    return ValueListenableBuilder(
      valueListenable: TransactionDB.instance.transactionListNotifier,
      builder:
          (BuildContext context, List<TransactionModel> newList, Widget? _) {
        return ListView.separated(
          padding: const EdgeInsets.only(
            left: 15,
            right: 15,
          ),
          separatorBuilder: ((context, index) {
            return const Divider();
          }),
          itemCount: newList.length,
          itemBuilder: (context, index) {
            final transaction = newList[index];
            return Card(
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.transparent,
                  child: Icon(
                    transaction.type == CategoryType.income
                        ? Icons.arrow_upward_outlined
                        : Icons.arrow_downward_outlined,
                    color: transaction.type == CategoryType.income
                        ? const Color(0xFF68AFF6)
                        : const Color(0xFFDE45FE),
                  ),
                ),
                title: Text(
                  '₹ ${transaction.amount}',
                  style: const TextStyle(color: Colors.black),
                ),
                subtitle: Text(
                  transaction.categoryModel.categoryName,
                ),
                trailing: Text(parseDateTime(transaction.date)),
                // onLongPress: () {
                // showDialog(
                //     context: context,
                //     builder: ((context) {
                //       return AlertDialog(
                //         title: const Text(
                //           'alert! ',
                //           style: TextStyle(color: Colors.red),
                //         ),
                //         content: const Text('Do you want to Delete.'),
                //         actions: [
                //           TextButton(
                //               onPressed: (() {
                //                 TransactionDB.instance
                //                     .deleteTransaction(transaction);
                //                 // CategoryDb().deleteCategory(
                //                 //   category.id,
                //                 // );
                //                 Navigator.of(context).pop();
                //               }),
                //               child: const Text(
                //                 'yes',
                //                 style: TextStyle(color: Colors.black),
                //               )),
                //           TextButton(
                //               onPressed: (() {
                //                 Navigator.of(context).pop();
                //               }),
                //               child: const Text('no',
                //                   style: TextStyle(color: Colors.black)))
                //         ],
                //       );
                //     }));
                // TransactionDB.instance.deleteTransaction(transaction);
                // },
              ),
            );
          },
        );
      },
    );
    // return ListView.separated(
    //   separatorBuilder: ((context, index) {
    //     return Divider();
    //   }),
    //   itemCount: 40,
    //   itemBuilder: (context, index) {
    //     return ListTile(
    //       title: Text(
    //         ' 1lk kj ',
    //         style: TextStyle(color: Colors.black),
    //       ),
    //     );
    //   },
    // );
  }

  String parseDateTime(DateTime date) {
    final dateFormatted = DateFormat.MMMMd().format(date);
    //using split we split the date into two parts
    final splitedDate = dateFormatted.split(' ');
    //here _splitedDate.last is second word that is month name and other one is the first word
    return "${splitedDate.last}  ${splitedDate.first} ";
  }
}
