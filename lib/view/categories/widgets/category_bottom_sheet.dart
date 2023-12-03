import 'package:animated_snack_bar/animated_snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:money_track/provider/category_provider.dart';
import 'package:money_track/provider/category_type_provider.dart';

import 'package:money_track/models/categories_model/category_model.dart';
import 'package:money_track/core/colors.dart';
import 'package:provider/provider.dart';

categoryShowBottomSheetApp(BuildContext context) async {
  final formKey = GlobalKey<FormState>();
  final nameEditingController = TextEditingController();
  showModalBottomSheet(
      // backgroundColor: Colors.transparent,
      context: context,
      builder: ((context) {
        return Form(
          key: formKey,
          child: SingleChildScrollView(
            child: SizedBox(
              height: 700,
              // width: 200,
              child: Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 15),
                    child: Center(
                        child: Text(
                      'Add Category',
                      style: TextStyle(fontSize: 18),
                    )),
                  ),
                  const Padding(
                    padding: EdgeInsets.all(10.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        RadioButton(title: 'Income', type: CategoryType.income),
                        RadioButton(
                            title: 'Expense', type: CategoryType.expense),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: TextFormField(
                      controller: nameEditingController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Enter Category';
                        }
                        return null;
                      },
                      decoration: const InputDecoration(
                        labelText: 'Category Name',
                        // floatingLabelStyle: TextStyle(
                        //   color: Colors.black,
                        // ),
                        border: OutlineInputBorder(),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: ColorConstants.themeDarkBlue,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(30.0),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(
                          20,
                        ),
                      ),
                      child: Consumer<CategoryTypeProvider>(
                          builder: (context, value, child) {
                        return ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            elevation: 0,
                            shape: const StadiumBorder(),
                          ),
                          onPressed: () {
                            if (formKey.currentState!.validate()) {
                              // If the form is valid, display a snackbar. In the real world,

                              AnimatedSnackBar.rectangle(
                                'Success',
                                'Category Added Successfully',
                                type: AnimatedSnackBarType.success,
                                brightness: Brightness.light,
                                duration: const Duration(
                                  seconds: 3,
                                ),
                              ).show(
                                context,
                              );
                            }
                            final name = nameEditingController.text;
                            if (name.isEmpty) {
                              return;
                            }
                            // final type =
                            //     CategoryTypeProvider().selectCategoryProvider;
                            final category = CategoryModel(
                              id: DateTime.now()
                                  .millisecondsSinceEpoch
                                  .toString(),
                              type: value.selectCategoryProvider,
                              categoryName: name,
                            );

                            context
                                .read<CategoryProvider>()
                                .insertCategory(category);
                            Navigator.of(context).pop();
                          },
                          child: const Hero(
                            tag: 'CategoryAppBottomSheet',
                            child: Text(
                              'Add',
                              style: TextStyle(
                                // color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }));
}

class RadioButton extends StatelessWidget {
  const RadioButton({
    super.key,
    required this.title,
    required this.type,
  });

  final String title;
  final CategoryType type;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Consumer<CategoryTypeProvider>(builder: (context, provider, child) {
          return Radio<CategoryType>(
            value: type,
            groupValue: provider.selectCategoryProvider,
            onChanged: (value) {
              provider.onChanging(value, type);
            },
          );
        }),
        Text(title),
      ],
    );
  }
}
