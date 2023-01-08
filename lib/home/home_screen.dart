import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:money_track/home/widgets/navigation_drawer.dart';
import 'package:money_track/home/widgets/floating_action_button.dart';
import 'package:money_track/widgets/show_custom_dailogue.dart';
import 'package:money_track/home/widgets/transaction_list.dart';
import 'package:rive/rive.dart';

import '../widgets/animated_button.dart';

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
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: (() {
            scaffoldKey.currentState?.openDrawer();
          }),
          icon: const Icon(
            Icons.menu_open,
          ),
        ),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Home',
        ),
        actions: [
          IconButton(
            onPressed: (() {}),
            icon: const Icon(
              Icons.search,
            ),
          ),
        ],
      ),
      drawer: NavigationDrawer(),
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
                      fit: BoxFit.cover,
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
                              Text(
                                '$totalAmount',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 25,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                              const Text(
                                'Total',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 30,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                children: [
                                  Text(
                                    '$totalAmount',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 25,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                  const Text(
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
                                width: 20,
                              ),
                              Column(
                                children: [
                                  Text(
                                    '$totalAmount',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 25,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                  const Text(
                                    'Income',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
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
                    // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Recent Transactions",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(
                        width: 80,
                      ),
                      TextButton.icon(
                        label: const Text(
                          'View all',
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
                        icon: const Icon(
                          Icons.remove_red_eye_outlined,
                          color: Color(
                            0xFF470FFF,
                          ),
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
      floatingActionButton: CustomFABWidget(),
    );
  }
}
