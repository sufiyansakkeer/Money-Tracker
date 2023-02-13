import 'package:flutter/material.dart';
import 'package:money_track/db/category/db_category.dart';
import 'package:money_track/constants/color/colors.dart';

import '../../models/categories_model/category_model.dart';

class ExpenseTransaction extends StatelessWidget {
  const ExpenseTransaction({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: themeDarkBlue,
      child: ValueListenableBuilder(
        valueListenable: CategoryDb().expenseCategoryListListener,
        builder: ((BuildContext ctx, List<CategoryModel> newList, Widget? _) {
          return LayoutBuilder(builder: (context, constraints) {
            return GridView.builder(
              itemCount: newList.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: constraints.maxWidth > 700 ? 4 : 2,
                crossAxisSpacing: 0,
                mainAxisSpacing: 10.0,
                childAspectRatio: (2 / 1.38),
              ),
              itemBuilder: ((
                context,
                index,
              ) {
                final category = newList[index];
                return Padding(
                  padding: const EdgeInsets.only(
                    left: 5,
                    top: 10,
                    right: 5,
                  ),
                  child: Card(
                    color: expenseColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                      //set border radius more than 50% of height and width to make circle
                    ),
                    child: Container(
                      decoration: const BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage("assets/images/expense-card.png"),
                          fit: BoxFit.fill,
                        ),
                      ),
                      child: Stack(
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.close,
                                  size: 20,
                                ),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: ((context) {
                                      return AlertDialog(
                                        title: const Text(
                                          'alert! ',
                                          style: TextStyle(color: Colors.red),
                                        ),
                                        content: const Text(
                                            'Do you want to Delete.'),
                                        actions: [
                                          TextButton(
                                              onPressed: (() {
                                                CategoryDb().deleteCategory(
                                                  category.id,
                                                );
                                                Navigator.of(context).pop();
                                              }),
                                              child: const Text(
                                                'yes',
                                                style: TextStyle(
                                                    color: Colors.black),
                                              )),
                                          TextButton(
                                              onPressed: (() {
                                                Navigator.of(context).pop();
                                              }),
                                              child: const Text('no',
                                                  style: TextStyle(
                                                      color: Colors.black)))
                                        ],
                                      );
                                    }),
                                  );
                                },
                              ),
                              Column(
                                children: [
                                  Expanded(
                                    child: Center(
                                      child: Text(
                                        category.categoryName,
                                        style: const TextStyle(
                                          fontSize: 20,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            );
          });
        }),
      ),
    );
  }
}
