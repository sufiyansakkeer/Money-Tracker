import 'package:animations/animations.dart';

import 'package:flutter/material.dart';

import 'package:money_track/insights/transaction_graph_page.dart';

import 'package:money_track/categories/transaction_categories.dart';

import 'package:money_track/screens/home/home_screen.dart';
import 'package:money_track/navigation_drawer/navigation_drawer.dart';

class RootPage extends StatefulWidget {
  const RootPage({super.key});

  @override
  State<RootPage> createState() => _RootPageState();
}

class _RootPageState extends State<RootPage> {
  static ValueNotifier<int> currentIndexNotifier = ValueNotifier(0);

  var blueclr = const Color(0xFF2E49FB);
  // var nameOfTheUser = 'Sufiyan';
  // late RiveAnimationController _btnAnimationController;

  bool isShowSignInDialog = false;

  int? totalAmount = 100000;
  final transitionType = ContainerTransitionType.fade;

  final _pages = [
    const HomeScreen(),
    const TransactionCategories(),
    const TransactionInsightsAll(),
  ];

  @override
  void initState() {
    // _btnAnimationController = OneShotAnimation(
    //   "active",
    //   autoplay: false,
    // );
    super.initState();
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
          title: LayoutBuilder(builder: (context, constraints) {
            return Text(
              'Money Track',
              style: TextStyle(
                fontSize: constraints.maxWidth > 700 ? 30 : 20,
              ),
            );
          }),
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
              unselectedItemColor: Colors.black,
              iconSize: 35,
              elevation: 0,
              currentIndex: updatedIndex,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(
                    Icons.home_outlined,
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
          },
        ),
        drawer: const NavigationDrawerClass(),
      ),
    );
  }
}
