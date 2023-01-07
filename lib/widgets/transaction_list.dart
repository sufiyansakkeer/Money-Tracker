import 'package:flutter/material.dart';

class TransactionListAll extends StatefulWidget {
  const TransactionListAll({super.key});

  @override
  State<TransactionListAll> createState() => _TransactionListAllState();
}

class _TransactionListAllState extends State<TransactionListAll> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: (() {}),
            icon: Icon(
              Icons.search,
            ),
          ),
        ],
        title: Text(
          'Transaction List',
        ),
      ),
      body: TransactionList(),
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
    return ListView.separated(
      separatorBuilder: ((context, index) {
        return Divider();
      }),
      itemCount: 40,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(
            ' 1lk kj ',
            style: TextStyle(color: Colors.black),
          ),
        );
      },
    );
  }
}
