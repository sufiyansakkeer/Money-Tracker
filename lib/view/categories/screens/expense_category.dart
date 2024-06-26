import 'package:flutter/material.dart';
import 'package:money_track/provider/category_provider.dart';

import 'package:money_track/core/constants/colors.dart';
import 'package:provider/provider.dart';

class ExpenseTransaction extends StatelessWidget {
  const ExpenseTransaction({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: ColorConstants.themeColor,
      child: Consumer<CategoryProvider>(
        builder: ((context, value, child) {
          value.refreshUI();
          return LayoutBuilder(builder: (context, constraints) {
            return GridView.builder(
              itemCount: value.expenseCategoryProvider.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: constraints.maxWidth > 700 ? 6 : 2,
                crossAxisSpacing: 0,
                mainAxisSpacing: 10.0,
                childAspectRatio: (2 / 1.5),
              ),
              itemBuilder: ((
                context,
                index,
              ) {
                final category = value.expenseCategoryProvider[index];
                return Padding(
                  padding: const EdgeInsets.only(
                    left: 5,
                    top: 10,
                    right: 5,
                  ),
                  child: Card(
                    color: ColorConstants.expenseColor,
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
                        // crossAxisAlignment: CrossAxisAlignment.end,
                        // mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
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
                                              context
                                                  .read<CategoryProvider>()
                                                  .deleteCategory(
                                                    category.id,
                                                  );

                                              Navigator.of(context).pop();
                                            }),
                                            child: const Text(
                                              'Yes',
                                              style: TextStyle(
                                                  color: Colors.black),
                                            ),
                                          ),
                                          TextButton(
                                            onPressed: (() {
                                              Navigator.of(context).pop();
                                            }),
                                            child: const Text(
                                              'No',
                                              style: TextStyle(
                                                color: Colors.black,
                                              ),
                                            ),
                                          ),
                                        ],
                                      );
                                    }),
                                  );
                                },
                              ),
                            ],
                          ),
                          Column(
                            children: [
                              Expanded(
                                child: Center(
                                  // mainAxisAlignment: MainAxisAlignment.start,
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
