import 'package:flutter/material.dart';

import '../db/category/db_category.dart';
import '../models/categories_model/category_model.dart';

class IncomeTransaction extends StatelessWidget {
  const IncomeTransaction({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: CategoryDb().incomeCategoryListListener,
      builder: ((BuildContext ctx, List<CategoryModel> newlIst, Widget? _) {
        return Container(
          color: Color(0xFF2E49FB),
          child: GridView.builder(
            itemCount: newlIst.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 0,
              mainAxisSpacing: 10.0,
              childAspectRatio: (2 / 1.2),
            ),
            itemBuilder: ((
              context,
              index,
            ) {
              final category = newlIst[index];
              return Padding(
                padding: const EdgeInsets.only(
                  left: 5,
                  top: 10,
                  right: 5,
                ),
                child: Card(
                  color: const Color(0xFF68AFF6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                    //set border radius more than 50% of height and width to make circle
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage("assets/images/income-card.png"),
                        fit: BoxFit.fill,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.close,
                            size: 20,
                          ),
                          onPressed: () {
                            CategoryDb().deleteCategory(
                              category.id,
                            );
                          },
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(category.categoryName),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        );
      }),
    );
  }
}
