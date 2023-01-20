import 'package:flutter/material.dart';
import 'package:money_track/categories/category_app_popup.dart';
import 'package:money_track/categories/expense_category.dart';
import 'package:money_track/categories/income_category.dart';
import 'package:money_track/db/category/db_category.dart';

import 'add_category.dart';

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
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(50.0),
          child: AppBar(
            backgroundColor: const Color(0xFF2E49FB),
            elevation: 0,
            bottom: TabBar(
              // unselectedLabelColor: const Color(0xFFFFFFFF),
              indicatorSize: TabBarIndicatorSize.label,
              indicator: BoxDecoration(
                borderRadius: BorderRadius.circular(110),
                color: Colors.transparent,
              ),
              tabs: [
                Tab(
                  child: Container(
                    height: 70,
                    decoration: BoxDecoration(
                      color: const Color(0xFF68AFF6),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                        color: const Color(0xFF68AFF6),
                        width: 1,
                      ),
                    ),
                    child: const Align(
                      alignment: Alignment.center,
                      child: Text(
                        "Income",
                        style: TextStyle(fontSize: 17),
                      ),
                    ),
                  ),
                ),
                Tab(
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFDE45FE),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                        color: const Color(0xFFDE45FE),
                        width: 1,
                      ),
                    ),
                    child: const Align(
                      alignment: Alignment.center,
                      child: Text(
                        "Expense",
                        style: TextStyle(fontSize: 17),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        body: const TabBarView(
          children: [
            IncomeTransaction(),
            ExpenseTransaction(),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          //  FloatingActionButton(
          //   child: Icon(Icons.add),
          //   onPressed: (() {
          //     showGeneralDialog(
          //       context: context,
          //       pageBuilder: (ctx, a1, a2) {
          //         return Container();
          //       },
          //       transitionBuilder: (ctx, a1, a2, child) {
          //         var curve = Curves.easeInOut.transform(a1.value);
          //         return Transform.scale(
          //           scale: curve,
          //           child: _dialog(ctx),
          //         );
          //       },
          //       transitionDuration: const Duration(milliseconds: 300),
          //     );
          //   }),
          // ),
          onPressed: () {
            //  print('ia, category');
            showCategoryAddPopup(context);
          },
          // ignore: sort_child_properties_last
          child: const Icon(
            Icons.add,
            color: Color(0xFF2E49FB),
          ),
          backgroundColor: Colors.white,
          // foregroundColor: const Color.fromARGB(255, 10, 10, 10),
          // splashColor: const Color.fromARGB(255, 245, 245, 245),
        ),
        // CustomCategoriesWidget(),
      ),
    );
  }
}
