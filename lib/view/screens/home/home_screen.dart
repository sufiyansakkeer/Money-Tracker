import 'package:flutter/material.dart';
import 'package:money_track/provider/transaction_provider.dart';

import 'package:money_track/core/colors.dart';
import 'package:money_track/view/screens/home/widgets/floating_action_button.dart';
import 'package:money_track/view/transaction/recent_transaction/recent_transaction.dart';
import 'package:money_track/view/transaction/view_all_transaction.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // CategoryDb.instance.refreshUI();
    // TransactionDB.instance.refreshUi();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      context.read<ProviderTransaction>().overviewGraphTransactions =
          context.read<ProviderTransaction>().transactionListProvider;
    });
    // incomeAndExpense();
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
                  child: Card(
                    elevation: 9,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
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
                        child: Consumer<ProviderTransaction>(builder:
                            (context, incomeAndExpenseProvider, child) {
                          return Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                children: [
                                  Text(
                                    incomeAndExpenseProvider.totalBalance < 0
                                        ? 'Lose'
                                        : 'Total',
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
                                    //here i used abs to avoid the negative values
                                    '₹${incomeAndExpenseProvider.totalBalance.abs().toString()}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 30,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Column(
                                    children: [
                                      const Row(
                                        children: [
                                          Icon(
                                            Icons.arrow_upward_outlined,
                                            color: Colors.white,
                                          ),
                                          Text(
                                            'Income',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(
                                        height: 5,
                                      ),
                                      Text(
                                        '₹${incomeAndExpenseProvider.incomeTotal}',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 25,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Column(
                                    children: [
                                      const Row(
                                        children: [
                                          Icon(
                                            Icons.arrow_downward_outlined,
                                            color: Colors.white,
                                          ),
                                          Text(
                                            'Expense',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(
                                        height: 5,
                                      ),
                                      Text(
                                        '₹${incomeAndExpenseProvider.expenseTotal.toString()}',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 25,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        // softWrap: false,
                                        // maxLines: 1,
                                      ),
                                    ],
                                  ),
                                ],
                              )
                            ],
                          );
                        }),
                      ),
                    ),
                  ),
                ),
                // ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Recent Transactions",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Consumer<ProviderTransaction>(
                      builder: (context, newList, child) {
                        return newList.transactionListProvider.isEmpty
                            ? const Padding(
                                padding: EdgeInsets.only(right: 10),
                                child: Text(
                                  '',
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
                                ),
                              )
                            : ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      ColorConstants.secondaryThemeBlue,
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
                                  style: TextStyle(
                                      color: ColorConstants.themeDarkBlue),
                                ),
                              );
                      },
                    ),
                  ],
                ),
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
