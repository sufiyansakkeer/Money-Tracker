import 'package:flutter/material.dart';
import 'package:money_track/widgets/transaction_list.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int? totalAmount = 100000;
  var blueclr = const Color(0xFF470FFF);
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
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              children: [
                Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFF470FFF),
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
                        top: 50,
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
                                    fontSize: 25,
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
                                      'Total',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 25,
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
                                      'Total',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 25,
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
                        SizedBox(
                          width: 125,
                        ),
                        IconButton(
                          onPressed: (() {}),
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
            const TransactionListAll()
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (() {}),
        tooltip: 'Increment',
        child: const Icon(
          Icons.add,
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        items: [
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
