import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:money_track/categories/transaction_categories.dart';
import 'package:money_track/graph/Transaction_graph.dart';
import 'package:money_track/home/home_screen.dart';

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
    HomeScreen(),
    TransactionCategories(),
    TransactionGraph(),
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
    return Scaffold(
      body: ValueListenableBuilder(
          valueListenable: currentIndexNotifier,
          builder: ((context, updatedIndex, child) {
            return _pages[updatedIndex];
          })),
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
        builder: (BuildContext context, updatedIndex, Widget? child) {
          return BottomNavigationBar(
            onTap: (newIndex) {
              currentIndexNotifier.value = newIndex;
            },
            currentIndex: updatedIndex,
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
          );
        },
      ),
    );
  }
}
