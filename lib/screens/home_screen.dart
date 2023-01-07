import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:money_track/widgets/floating_action_button.dart';
import 'package:money_track/widgets/transaction_list.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final transitionType = ContainerTransitionType.fade;
  int? totalAmount = 100000;
  var blueclr = const Color(0xFF2E49FB);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: (() {}),
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
          )
          // Container(
          //   width: double.infinity,
          //   child: ListView(
          //     children: [TransactionListAll()],
          //   ),
          // ),
        ],
      ),
      floatingActionButton: CustomFABWidget(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(
                Icons.home,
              ),
              label: 'Home',
              backgroundColor: Colors.white),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.category_outlined,
            ),
            label: 'Categories',
            backgroundColor: Color(0xFF470FFF),
          ),
          BottomNavigationBarItem(
              icon: Icon(
                Icons.auto_graph_outlined,
              ),
              label: 'Graph',
              backgroundColor: Colors.white),
        ],
      ),
    );
  }
}
