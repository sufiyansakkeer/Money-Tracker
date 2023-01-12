import 'package:animations/animations.dart';

import 'package:flutter/material.dart';
import 'package:money_track/Insights/transaction_graph.dart';
import 'package:money_track/categories/transaction_categories.dart';

import 'package:money_track/home/home_screen.dart';
import 'package:money_track/home/widgets/navigation_drawer.dart';

class RootPage extends StatefulWidget {
  const RootPage({super.key});

  @override
  State<RootPage> createState() => _RootPageState();
}

class _RootPageState extends State<RootPage> {
  static ValueNotifier<int> currentIndexNotifier = ValueNotifier(0);
  var nameOfTheUser = 'Sufiyan';
  // late RiveAnimationController _btnAnimationController;

  bool isShowSignInDialog = false;
  final transitionType = ContainerTransitionType.fade;
  int? totalAmount = 100000;
  var blueclr = const Color(0xFF2E49FB);

  final _pages = [
    const HomeScreen(),
    const TransactionCategories(),
    const TransactionInsights(),
  ];
  @override
  void initState() {
    // _btnAnimationController = OneShotAnimation(
    //   "active",
    //   autoplay: false,
    // );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        final shouldPop = await showMyDailogue();
        return shouldPop ?? false;
      },
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text(
            'Money Tracker',
          ),
          elevation: 0,
        ),
        body: ValueListenableBuilder(
          valueListenable: currentIndexNotifier,
          builder: ((
            context,
            updatedIndex,
            child,
          ) {
            return _pages[updatedIndex];
          }),
        ),
        bottomNavigationBar: ValueListenableBuilder(
          valueListenable: currentIndexNotifier,
          builder: (
            BuildContext context,
            updatedIndex,
            Widget? child,
          ) {
            return BottomNavigationBar(
              iconSize: 35,
              elevation: 0,
              currentIndex: updatedIndex,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(
                    Icons.home,
                  ),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Icon(
                    Icons.category_outlined,
                  ),
                  label: 'Category',
                ),
                BottomNavigationBarItem(
                  icon: Icon(
                    Icons.insights_outlined,
                  ),
                  label: 'Insights',
                ),
              ],
              onTap: (newIndex) {
                currentIndexNotifier.value = newIndex;
              },
            );
            // DotNavigationBar(
            //   paddingR: const EdgeInsets.only(
            //     bottom: 5,
            //     top: 5,
            //   ),
            //   enableFloatingNavBar: true,
            //   boxShadow: [
            //     BoxShadow(
            //       color: Colors.transparent,
            //     )
            //   ],
            //   // List<BoxShadow> boxShadow =  [BoxShadow(color: Colors.transparent, spreadRadius: 0, blurRadius: 0, offset: Offset(0, 0))],
            //   backgroundColor: const Color(0xFF2E49FB),
            //   onTap: (newIndex) {
            //     currentIndexNotifier.value = newIndex;
            //   },
            //   currentIndex: updatedIndex,
            //   items: [
            //     DotNavigationBarItem(
            //       icon: const Icon(
            //         Icons.home,
            //       ),
            //       // label: 'Home',
            //       selectedColor: const Color.fromARGB(
            //         255,
            //         255,
            //         255,
            //         255,
            //       ),
            //     ),
            //     DotNavigationBarItem(
            //       icon: const Icon(
            //         Icons.category_outlined,
            //       ),
            //       // label: 'Categories',
            //       selectedColor: Colors.white,
            //     ),
            //     DotNavigationBarItem(
            //       icon: const Icon(
            //         Icons.auto_graph_outlined,
            //       ),
            //       // label: 'Graph',
            //       selectedColor: Colors.white,
            //     ),
            //   ],
            // );
          },
        ),
        drawer: const NavigationDrawer(),
      ),
    );
  }

  Future<bool?> showMyDailogue() => showDialog(
        context: context,
        builder: ((context) => AlertDialog(
              content: const Text(
                'Do you want to exit',
              ),
              actions: [
                TextButton(
                  onPressed: (() {
                    return Navigator.pop(context, true);
                  }),
                  child: const Text(
                    'Yes',
                  ),
                ),
                TextButton(
                  onPressed: (() {
                    return Navigator.pop(context, false);
                  }),
                  child: const Text(
                    'cancel',
                  ),
                )
              ],
            )),
      );
}
