import 'package:animations/animations.dart';

import 'package:flutter/material.dart';

import 'package:money_track/Insights/transaction_graph_page.dart';

import 'package:money_track/categories/transaction_categories.dart';

import 'package:money_track/screens/home/home_screen.dart';
import 'package:money_track/screens/home/widgets/navigation_drawer.dart';

class RootPage extends StatefulWidget {
  const RootPage({super.key});

  @override
  State<RootPage> createState() => _RootPageState();
}

class _RootPageState extends State<RootPage> {
  static ValueNotifier<int> currentIndexNotifier = ValueNotifier(0);
  // var nameOfTheUser = 'Sufiyan';
  // late RiveAnimationController _btnAnimationController;

  bool isShowSignInDialog = false;
  final transitionType = ContainerTransitionType.fade;
  int? totalAmount = 100000;
  var blueclr = const Color(0xFF2E49FB);

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

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        final shouldPop = await showMyDailogue();
        return shouldPop ?? false;
      },
      child: Scaffold(
        appBar: AppBar(
          // leading: Builder(
          //   builder: (BuildContext context) {
          //     return ElevatedButton(
          //       onPressed: (() {
          //         Scaffold.of(context).openDrawer();
          //       }),
          //       child: const Icon(
          //         Icons.menu_open_rounded,
          //       ),
          //     );
          //   },
          // ),
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
