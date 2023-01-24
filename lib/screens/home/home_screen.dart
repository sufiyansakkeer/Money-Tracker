import 'package:flutter/material.dart';
import 'package:money_track/Transaction/recent_transaction/recent_transaction.dart';
import 'package:money_track/Transaction/view_all_transaction.dart';
import 'package:money_track/db/category/db_category.dart';
import 'package:money_track/db/transaction/db_transaction_function.dart';
import 'package:money_track/db/transaction/income_and_expense.dart';
import 'package:money_track/screens/home/widgets/floating_action_button.dart';
import 'package:money_track/widgets/colors.dart';

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
                    child: Padding(
                      padding: const EdgeInsets.only(top: 30, bottom: 30),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ValueListenableBuilder(
                            valueListenable: totalBalance,
                            builder: (BuildContext context, dynamic value,
                                Widget? child) {
                              return Column(
                                children: [
                                  Text(
                                    totalBalance.value < 0 ? 'Lose' : 'Total',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 23,
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
                                      fontSize: 30,
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
                                valueListenable: incomeTotal,
                                builder: (BuildContext context, dynamic value,
                                    Widget? child) {
                                  return Column(
                                    children: [
                                      const Text(
                                        'Income',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 23,
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
                                          fontSize: 30,
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
                                valueListenable: expenseTotal,
                                builder: (BuildContext context, dynamic value,
                                    Widget? child) {
                                  return Column(
                                    children: [
                                      const Text(
                                        'Expense',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 23,
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
                                          fontSize: 30,
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
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: secondaryThemeBlue,
                    elevation: 0,
                    shape: const StadiumBorder(),
                  ),
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
                    style: TextStyle(color: themeDarkBlue),
                  ),
                )
              ],
            ),
          ),
          const Expanded(
            child: SizedBox(
              width: double.infinity,
              child: RecentTransactionList(),
            ),
          ),
        ],
      ),
      floatingActionButton: const CustomAddWidget(),
    );
  }
}
