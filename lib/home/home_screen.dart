import 'package:flutter/material.dart';
import 'package:money_track/db/category/db_category.dart';
import 'package:money_track/db/transaction/db_transaction_function.dart';
import 'package:money_track/home/widgets/floating_action_button.dart';

import 'package:money_track/Transaction/transaction_list.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  var scaffoldKey = GlobalKey<ScaffoldState>();
  int? totalAmount = 100000;
  @override
  Widget build(BuildContext context) {
    CategoryDb.instance.refreshUI();
    TransactionDB.instance.refreshUi();
    return Scaffold(
      body: Column(
        children: [
          Stack(
            children: [
              Container(
                decoration: const BoxDecoration(
                  color: Color(0xFF2E49FB),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(50),
                    bottomRight: Radius.circular(50),
                  ),
                ),
                width: double.infinity,
                height: 140,
              ),
              Container(
                color: Colors.transparent,
                // height: 100,
                width: double.infinity,
                height: 345,
                child: Stack(
                  children: [
                    Image.asset(
                      'assets/images/Rectangle 24.png',
                      fit: BoxFit.fill,
                      width: 500,

                      // width: ,
                      // height: 500,
                    ),
                    Positioned(
                      left: 70,
                      right: 70,
                      top: 70,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Column(
                            children: [
                              const Text(
                                'Total',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 25,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                              Text(
                                '$totalAmount',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 25,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 40,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                children: [
                                  const Text(
                                    'Expense',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 25,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                  Text(
                                    '$totalAmount',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 25,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(
                                width: 20,
                              ),
                              Column(
                                children: [
                                  const Text(
                                    'Income',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 25,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                  Text(
                                    '$totalAmount',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 25,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
              // ),
              Positioned(
                top: 300,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Recent Transactions",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(
                        width: 100,
                      ),
                      TextButton(
                        onPressed: (() {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: ((context) {
                                return const TransactionListAll();
                              }),
                            ),
                          );
                        }),
                        child: const Text(
                          'View all',
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
          const Expanded(
            child: SizedBox(
              width: double.infinity,
              child: TransactionList(),
            ),
          ),
          // AnimatedBtn(
          //   btnAnimationController: _btnAnimationController,
          //   press: () {
          //     _btnAnimationController.isActive = true;

          //     Future.delayed(
          //       const Duration(milliseconds: 800),
          //       () {
          //         setState(() {
          //           isShowSignInDialog = true;
          //         });
          //         showCustomDialog(
          //           context,
          //           onValue: (_) {
          //             setState(() {
          //               isShowSignInDialog = false;
          //             });
          //           },
          //         );
          //       },
          //     );
          //   },
          // ),
          // Container(
          //   width: double.infinity,
          //   child: ListView(
          //     children: [TransactionListAll()],
          //   ),
          // ),
        ],
      ),
      floatingActionButton: const CustomAddWidget(),

      //  FloatingActionButton(
      //   child: Icon(Icons.add),
      //   onPressed: (() {
      //     showGeneralDialog(
      //       context: context,
      //       pageBuilder: (ctx, a1, a2) {
      //         return Container();
      //       },
      //       transitionBuilder: (ctx, a1, a2, child) {
      //         var curve = Curves.easeInOut.transform(a1.value);
      //         return Transform.scale(
      //           scale: curve,
      //           child: _dialog(ctx),
      //         );
      //       },
      //       transitionDuration: const Duration(milliseconds: 300),
      //     );
      //   }),
      // ),
      // CustomFABWidget(),
    );
  }
//popping alert box
  // Widget _dialog(BuildContext context) {
  //   return AlertDialog(
  //     title: const Text("Dialog title"),
  //     content: const Text("Simple Dialog content"),
  //     actions: <Widget>[
  //       TextButton(
  //           onPressed: () {
  //             Navigator.of(context).pop();
  //           },
  //           child: const Text("Okay"))
  //     ],
  //   );
  // }
}
