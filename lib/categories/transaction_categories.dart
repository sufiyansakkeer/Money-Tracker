import 'package:buttons_tabbar/buttons_tabbar.dart';
import 'package:flutter/material.dart';
import 'package:money_track/categories/widgets/category_bottom_sheet.dart';
import 'package:money_track/categories/screens/expense_category.dart';
import 'package:money_track/categories/screens/income_category.dart';
import 'package:money_track/constants/color/colors.dart';
import 'package:money_track/db/category/db_category.dart';

class TransactionCategories extends StatefulWidget {
  const TransactionCategories({super.key});

  @override
  State<TransactionCategories> createState() => _TransactionCategoriesState();
}

class _TransactionCategoriesState extends State<TransactionCategories>
    with SingleTickerProviderStateMixin {
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
          children: <Widget>[
            Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: themeDarkBlue,
                border: Border.all(
                  width: 0,
                  color: themeDarkBlue,
                ),
              ),
              width: double.infinity,
              child: ButtonsTabBar(
                contentPadding: const EdgeInsets.symmetric(horizontal: 45),
                borderColor: const Color.fromARGB(255, 255, 98, 0),
                backgroundColor: Colors.white,
                unselectedBackgroundColor: const Color(0xFFB8B0B0),
                labelSpacing: 30,
                labelStyle: const TextStyle(
                  color: themeDarkBlue,
                ),
                unselectedLabelStyle: const TextStyle(color: themeDarkBlue),
                tabs: const [
                  Tab(
                    iconMargin: EdgeInsets.all(30),
                    text: 'Income',
                  ),
                  Tab(
                    text: 'Expense',
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
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
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
