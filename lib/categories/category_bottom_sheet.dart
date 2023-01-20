import 'package:animated_snack_bar/animated_snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:money_track/db/category/db_category.dart';
import 'package:money_track/models/categories_model/category_model.dart';

ValueNotifier<CategoryType> selectCategoryNotifier =
    ValueNotifier(CategoryType.income);

categoryShowBottomSheetApp(BuildContext context) async {
  final formKey = GlobalKey<FormState>();
  final nameEditingController = TextEditingController();
  showModalBottomSheet(
      context: context,
      builder: ((context) {
        return Form(
          key: formKey,
          child: SingleChildScrollView(
            child: SizedBox(
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
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: const [
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
                            color: Color(0xFF2E49FB),
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
                      child: ElevatedButton(
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
                            ).show(
                              context,
                            );
                          }
                          final name = nameEditingController.text;
                          if (name.isEmpty) {
                            return;
                          }
                          final type = selectCategoryNotifier.value;
                          final category = CategoryModel(
                            id: DateTime.now()
                                .millisecondsSinceEpoch
                                .toString(),
                            type: type,
                            categoryName: name,
                          );

                          CategoryDb.instance.insertCategory(category);
                          Navigator.of(context).pop();
                        },
                        child: const Text(
                          'Add',
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
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
        ValueListenableBuilder(
            valueListenable: selectCategoryNotifier,
            builder: (BuildContext ctx, CategoryType newCategory, Widget? _) {
              return Radio<CategoryType>(
                fillColor: MaterialStateColor.resolveWith(
                    (states) => const Color(0xFF2E49FB)),
                focusColor: MaterialStateColor.resolveWith(
                    (states) => const Color.fromARGB(255, 255, 0, 0)),
                value: type,
                groupValue: newCategory,
                onChanged: (value) {
                  if (value == null) {
                    return;
                  }
                  selectCategoryNotifier.value = value;
                  selectCategoryNotifier.notifyListeners();
                },
              );
            }),
        Text(title),
      ],
    );
  }
}
