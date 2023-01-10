import 'package:animations/animations.dart';
import 'package:dot_navigation_bar/dot_navigation_bar.dart';
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
          title: Text(
            'Money Tracker',
          ),
          elevation: 0,
          actions: [
            IconButton(
              onPressed: (() {}),
              icon: Icon(
                Icons.search,
              ),
            )
          ],
        ),
        body: ValueListenableBuilder(
          valueListenable: currentIndexNotifier,
          builder: ((context, updatedIndex, child) {
            return _pages[updatedIndex];
          }),
        ),
        bottomNavigationBar:

            // SafeArea(
            //   child: Container(
            //     padding: EdgeInsets.all(10),
            //     decoration: BoxDecoration(
            //       color: Color(0xFF2E49FB).withOpacity(1),
            //       borderRadius: BorderRadius.all(
            //         Radius.circular(
            //           24,
            //         ),
            //       ),
            //     ),
            //     child: Row(
            //       children: [
            //         SizedBox(
            //           height: 36,
            //           width: 36,
            //           child: RiveAnimation.asset("assets/rive/button.riv"),
            //         )
            //       ],
            //     ),
            //   ),
            // ),
            ValueListenableBuilder(
          valueListenable: currentIndexNotifier,
          builder: (
            BuildContext context,
            updatedIndex,
            Widget? child,
          ) {
            return DotNavigationBar(
              paddingR: const EdgeInsets.only(
                bottom: 5,
                top: 5,
              ),
              enableFloatingNavBar: true,
              boxShadow: [
                BoxShadow(
                  color: Colors.transparent,
                )
              ],
              // List<BoxShadow> boxShadow =  [BoxShadow(color: Colors.transparent, spreadRadius: 0, blurRadius: 0, offset: Offset(0, 0))],
              backgroundColor: const Color(0xFF2E49FB),
              onTap: (newIndex) {
                currentIndexNotifier.value = newIndex;
              },
              currentIndex: updatedIndex,
              items: [
                DotNavigationBarItem(
                  icon: const Icon(
                    Icons.home,
                  ),
                  // label: 'Home',
                  selectedColor: const Color.fromARGB(
                    255,
                    255,
                    255,
                    255,
                  ),
                ),
                DotNavigationBarItem(
                  icon: const Icon(
                    Icons.category_outlined,
                  ),
                  // label: 'Categories',
                  selectedColor: Colors.white,
                ),
                DotNavigationBarItem(
                  icon: const Icon(
                    Icons.auto_graph_outlined,
                  ),
                  // label: 'Graph',
                  selectedColor: Colors.white,
                ),
              ],
            );
          },
        ),
        drawer: NavigationDrawer(),
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
