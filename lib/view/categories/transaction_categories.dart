import 'package:buttons_tabbar/buttons_tabbar.dart';
import 'package:flutter/material.dart';
import 'package:money_track/provider/category_provider.dart';
import 'package:money_track/view/categories/widgets/category_bottom_sheet.dart';
import 'package:money_track/view/categories/screens/expense_category.dart';
import 'package:money_track/view/categories/screens/income_category.dart';
import 'package:money_track/core/constants/colors.dart';

import 'package:provider/provider.dart';

class TransactionCategories extends StatelessWidget {
  const TransactionCategories({super.key});

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback(
      (timeStamp) =>
          Provider.of<CategoryProvider>(context, listen: false).refreshUI(),
    );
    return Scaffold(
      body: DefaultTabController(
        length: 2,
        initialIndex: 0,
        child: Column(
          children: <Widget>[
            Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: ColorConstants.themeColor,
                border: Border.all(
                  width: 0,
                  color: ColorConstants.themeColor,
                ),
              ),
              width: double.infinity,
              child: ButtonsTabBar(
                contentPadding: const EdgeInsets.symmetric(horizontal: 45),
                borderColor: const Color.fromARGB(255, 255, 98, 0),
                backgroundColor: Colors.white,
                unselectedBackgroundColor: const Color(0xFFB8B0B0),
                labelSpacing: 30,
                labelStyle: TextStyle(
                  color: ColorConstants.themeColor,
                ),
                unselectedLabelStyle:
                    TextStyle(color: ColorConstants.themeColor),
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
