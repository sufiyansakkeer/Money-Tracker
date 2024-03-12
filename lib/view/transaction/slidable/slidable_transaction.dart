import 'package:flutter/material.dart';

import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:money_track/provider/transaction_provider.dart';

import 'package:money_track/models/categories_model/category_model.dart';
import 'package:money_track/models/transaction_model/transaction_model.dart';
import 'package:money_track/view/transaction/edit_transaction/edit_transaction.dart';
import 'package:provider/provider.dart';

class SlidableTransaction extends StatelessWidget {
  const SlidableTransaction({super.key, required this.transaction});

  final TransactionModel transaction;

  String parseDateTime(DateTime date) {
    final dateFormatted = DateFormat.MMMMd().format(date);
    //using split we split the date into two parts
    final splitedDate = dateFormatted.split(' ');
    //here _splitedDate.last is second word that is month name and other one is the first word
    return "${splitedDate.last}  ${splitedDate.first} ";
  }

  @override
  Widget build(BuildContext context) {
    return Slidable(
      endActionPane: ActionPane(motion: const StretchMotion(), children: [
        SlidableAction(
          onPressed: ((context) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: ((context) {
                  return EditTransaction(
                    obj: transaction,
                  );
                }),
              ),
            );
          }),
          icon: Icons.edit,
          foregroundColor: const Color(0xFF2E49FB),
        ),
        SlidableAction(
          onPressed: ((context) {
            showDialog(
                context: context,
                builder: ((context) {
                  return AlertDialog(
                    content: const Text(
                      'Do you want to Delete.',
                    ),
                    actions: [
                      TextButton(
                          onPressed: (() {
                            // TransactionDB.instance
                            //     .deleteTransaction(transaction);
                            Provider.of<ProviderTransaction>(context,
                                    listen: false)
                                .deleteTransaction(transaction);
                            Navigator.of(context).pop();
                          }),
                          child: const Text(
                            'yes',
                            style: TextStyle(
                              color: Colors.black,
                            ),
                          )),
                      TextButton(
                        onPressed: (() {
                          Navigator.of(context).pop();
                        }),
                        child: const Text(
                          'no',
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                    ],
                  );
                }));
          }),
          icon: Icons.delete,
          foregroundColor: Colors.red,
        ),
      ]),
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(
          //<-- SEE HERE
          // side: BorderSide(width: 1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: ListTile(
          onLongPress: () {},
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
          trailing: Text(
            parseDateTime(transaction.date),
          ),
        ),
      ),
    );
  }
}
