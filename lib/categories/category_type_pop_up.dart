import 'package:animated_snack_bar/animated_snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:money_track/db/category/db_category.dart';
import 'package:money_track/models/categories_model/category_model.dart';

Future<void> categoryTypePopUp(BuildContext context, CategoryType type) async {
  final formKey = GlobalKey<FormState>();
  final nameEditingController = TextEditingController();
  final categoryType = type;
  showDialog(
    context: context,
    builder: (ctx) {
      return Form(
        key: formKey,
        child: SimpleDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Center(child: Text('Add Category')),
          children: [
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
                    final type = categoryType;
                    final category = CategoryModel(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      type: type,
                      categoryName: name,
                    );

                    CategoryDb.instance.insertCategory(category);
                    Navigator.of(ctx).pop();
                  },
                  child: const Text(
                    'Add',
                    style: TextStyle(
                      color: Color(0xFFFFFFFF),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}
