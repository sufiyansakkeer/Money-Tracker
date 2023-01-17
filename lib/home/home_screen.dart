import 'package:flutter/material.dart';
import 'package:money_track/db/category/db_category.dart';
import 'package:money_track/db/transaction/db_transaction_function.dart';
import 'package:money_track/home/widgets/floating_action_button.dart';

import 'package:money_track/Transaction/transaction_list.dart';
import 'package:money_track/models/transaction_model/transaction_model.dart';

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
          Container(
            width: double.infinity,
            height: 280,
            child: Stack(
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
                Positioned(
                  top: 20,
                  left: 30,
                  right: 30,
                  child: Container(
                    height: 250,
                    width: 300,
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.all(
                        Radius.circular(30),
                      ),
                      border: Border.all(color: Colors.transparent),
                      image: const DecorationImage(
                        image: AssetImage(
                            "assets/images/WhatsApp Image 2023-01-17 at 12.06.12.jpg"),
                        fit: BoxFit.fill,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ValueListenableBuilder(
                          valueListenable:
                              TransactionDB.instance.transactionListNotifier,
                          builder: (BuildContext context,
                              List<TransactionModel> newList, Widget? child) {
                            return Column(
                              children: [
                                const Text(
                                  'Total',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
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
                            );
                          },
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Column(
                              children: [
                                const Text(
                                  'Expense',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
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
                                    fontSize: 20,
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
                  ),
                ),
                // ),
              ],
            ),
          ),
          Padding(
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

  // Future<void> transactionUi(TransactionDB obj) {
  //   final totalExpense;
  //   final totalIncome;
  // }
}
