import 'package:buttons_tabbar/buttons_tabbar.dart';
import 'package:flutter/material.dart';

import 'package:money_track/categories/category_bottom_sheet.dart';
import 'package:money_track/categories/expense_category.dart';
import 'package:money_track/categories/income_category.dart';
import 'package:money_track/constants/color/colors.dart';
import 'package:money_track/db/category/db_category.dart';

class TransactionCategories extends StatefulWidget {
  const TransactionCategories({super.key});

  @override
  State<TransactionCategories> createState() => _TransactionCategoriesState();
}

class _TransactionCategoriesState extends State<TransactionCategories> {
  @override
  void initState() {
    CategoryDb().refreshUI();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DefaultTabController(
        length: 2,
        initialIndex: 0,
        child: Column(
          // mainAxisAlignment: mai,
          children: <Widget>[
            Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  color: themeDarkBlue,
                  border: Border.all(width: 0, color: themeDarkBlue)),
              width: double.infinity,
              child: ButtonsTabBar(
                backgroundColor: Colors.white,
                unselectedBackgroundColor: const Color(0xFFCFCDCD),
                tabs: [
                  Tab(
                    // icon: Icon(
                    //   Icons.arrow_circle_up_rounded,
                    //   color: incomeColor,
                    // ),
                    // text: 'Income',
                    child: Container(
                      // decoration: BoxDecoration(color: incomeColor),
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 40),
                        child: Text(
                          'Income',
                          style: TextStyle(
                            color: themeDarkBlue,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Tab(
                    // text: 'Expense',
                    // icon: Icon(
                    //   Icons.arrow_downward_outlined,
                    //   color: expenseColor,
                    // ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 40),
                      child: Text(
                        'Expense',
                        style: TextStyle(color: themeDarkBlue),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Expanded(
                child: TabBarView(children: [
              IncomeTransaction(),
              ExpenseTransaction(),
            ]))
          ],
        ),
        // Scaffold(
        //   appBar: PreferredSize(
        //     preferredSize: const Size.fromHeight(50.0),
        //     child: AppBar(
        //       backgroundColor: const Color(0xFF2E49FB),
        //       elevation: 0,
        //       bottom: TabBar(
        //         // unselectedLabelColor: const Color(0xFFFFFFFF),
        //         indicatorSize: TabBarIndicatorSize.label,
        //         indicator: BoxDecoration(
        //           borderRadius: BorderRadius.circular(110),
        //           color: themeDarkBlue,
        //         ),
        //         tabs: [
        //           Tab(
        //             child: Container(
        //               height: 70,
        //               decoration: BoxDecoration(
        //                 color: incomeColor,
        //                 borderRadius: BorderRadius.circular(15),
        //                 border: Border.all(
        //                   color: const Color(0xFF68AFF6),
        //                   width: 1,
        //                 ),
        //               ),
        //               child: const Align(
        //                 alignment: Alignment.center,
        //                 child: Text(
        //                   "Income",
        //                   style: TextStyle(fontSize: 17),
        //                 ),
        //               ),
        //             ),
        //           ),
        //           Tab(
        //             child: Container(
        //               decoration: BoxDecoration(
        //                 color: Color.fromARGB(127, 223, 69, 254),
        //                 borderRadius: BorderRadius.circular(15),
        //                 border: Border.all(
        //                   color: Color.fromARGB(255, 255, 255, 255),
        //                   width: 3,
        //                 ),
        //               ),
        //               child: const Align(
        //                 alignment: Alignment.center,
        //                 child: Text(
        //                   "Expense",
        //                   style: TextStyle(fontSize: 17),
        //                 ),
        //               ),
        //             ),
        //           ),
        //         ],
        //       ),
        //     ),
        //   ),
        //   body: const TabBarView(
        //     children: [
        //       IncomeTransaction(),
        //       ExpenseTransaction(),
        //     ],
        //   ),
        //   floatingActionButton: FloatingActionButton(
        //     onPressed: () {
        //       //  print('ia, category');
        //       // showCategoryAddPopup(context);
        //       categoryShowBottomSheetApp(context);
        //     },
        //     // ignore: sort_child_properties_last
        //     child: const Icon(
        //       Icons.add,
        //       color: Color(0xFF2E49FB),
        //     ),
        //     backgroundColor: Colors.white,
        //     // foregroundColor: const Color.fromARGB(255, 10, 10, 10),
        //     // splashColor: const Color.fromARGB(255, 245, 245, 245),
        //   ),
        //   // CustomCategoriesWidget(),
        // ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          //  print('ia, category');
          // showCategoryAddPopup(context);
          categoryShowBottomSheetApp(context);
        },
        backgroundColor: Colors.white,
        foregroundColor: const Color.fromARGB(255, 10, 10, 10),
        splashColor: const Color.fromARGB(255, 245, 245, 245),
        child: const Icon(
          Icons.add,
          color: Color(0xFF2E49FB),
        ),
      ),
    );
  }
}
