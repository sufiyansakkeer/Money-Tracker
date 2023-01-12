import 'package:flutter/material.dart';
import 'package:money_track/categories/expense_category.dart';
import 'package:money_track/categories/income_category.dart';

import 'add_category.dart';

class TransactionCategories extends StatelessWidget {
  const TransactionCategories({super.key});

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
              unselectedLabelColor: const Color(0xFFFFFFFF),
              indicatorSize: TabBarIndicatorSize.label,
              indicator: BoxDecoration(
                borderRadius: BorderRadius.circular(40),
                color: const Color.fromARGB(255, 255, 255, 255),
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
                      child: Text("Expense"),
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
        floatingActionButton: const CustomCategoriesWidget(),
      ),
    );
  }
}
