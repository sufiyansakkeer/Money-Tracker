import 'package:flutter/material.dart';
import 'package:money_track/db/category/db_category.dart';
import 'package:money_track/db/transaction/db_transaction_function.dart';
import 'package:money_track/db/transaction/income_and_expense.dart';
import 'package:money_track/home/widgets/floating_action_button.dart';

import 'package:money_track/models/categories_model/category_model.dart';
import 'package:money_track/models/transaction_model/transaction_model.dart';
import 'package:money_track/Transaction/transaction_list.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    CategoryDb.instance.refreshUI();
    TransactionDB.instance.refreshUi();
    incomeAndExpense();
    return Scaffold(
      body: Column(
        children: [
          SizedBox(
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
                          "assets/images/WhatsApp Image 2023-01-17 at 12.06.12.jpg",
                        ),
                        fit: BoxFit.fill,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ValueListenableBuilder(
                          valueListenable: totalBalance,
                          builder: (BuildContext context, dynamic value,
                              Widget? child) {
                            return Column(
                              children: [
                                Text(
                                  totalBalance.value < 0 ? 'Damn' : 'Total',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                                Text(
                                  totalBalance.value.toString(),
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
                            ValueListenableBuilder(
                              valueListenable: expenseTotal,
                              builder: (BuildContext context, dynamic value,
                                  Widget? child) {
                                return Column(
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
                                      expenseTotal.value.toString(),
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
                            const SizedBox(
                              width: 20,
                            ),
                            ValueListenableBuilder(
                              valueListenable: incomeTotal,
                              builder: (BuildContext context, dynamic value,
                                  Widget? child) {
                                return Column(
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
                                      '${incomeTotal.value}',
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
    );
  }
}
