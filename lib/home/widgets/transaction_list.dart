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
                    fit: BoxFit.fitHeight,
                  ),
                ),
              ),
            ];
          },
          body: ListView.separated(
            separatorBuilder: ((context, index) {
              return const Divider();
            }),
            itemCount: 40,
            itemBuilder: (context, index) {
              return const ListTile(
                leading: Icon(Icons.home_work),
                title: Text(
                  ' 1lk kj ',
                  style: TextStyle(
                    color: Colors.black,
                  ),
                ),
              );
            },
          )),
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
    return Scaffold(
        body: ListView.separated(
      separatorBuilder: ((context, index) {
        return const Divider();
      }),
      itemCount: 40,
      itemBuilder: (context, index) {
        return const ListTile(
          title: Text(
            ' 1lk kj ',
            style: TextStyle(color: Colors.black),
          ),
        );
      },
    ));
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
}
