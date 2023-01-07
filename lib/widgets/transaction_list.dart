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
                actions: [
                  IconButton(
                    onPressed: (() {}),
                    icon: Icon(
                      Icons.search,
                    ),
                  ),
                ],
                expandedHeight: 200.0,
                floating: false,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                    centerTitle: true,
                    title: Text(
                      "My Transaction's",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.0,
                      ),
                    ),
                    background: Image.network(
                      "https://images.pexels.com/photos/396547/pexels-photo-396547.jpeg?auto=compress&cs=tinysrgb&h=350",
                      fit: BoxFit.cover,
                    )),
              ),
            ];
          },
          body: ListView.separated(
            separatorBuilder: ((context, index) {
              return Divider();
            }),
            itemCount: 40,
            itemBuilder: (context, index) {
              return const ListTile(
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
