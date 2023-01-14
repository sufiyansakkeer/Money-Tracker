import 'package:flutter/material.dart';
import 'package:money_track/db/category/db_category.dart';
import 'package:money_track/models/categories_model/category_model.dart';

ValueNotifier<CategoryType> selectCategoryNotifire =
    ValueNotifier(CategoryType.income);

Future<void> showCategoryAddPopup(
  BuildContext context,
) async {
  final _formKey = GlobalKey<FormState>();
  final nameEditingController = TextEditingController();
  showDialog(
    context: context,
    builder: (ctx) {
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
      return Form(
        key: _formKey,
        child: SimpleDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text('Add Category'),
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
              padding: const EdgeInsets.all(10.0),
              child: Row(
                children: const [
                  RadioButton(title: 'Income', type: CategoryType.income),
                  RadioButton(title: 'Expense', type: CategoryType.expense),
                ],
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
                    if (_formKey.currentState!.validate()) {
                      // If the form is valid, display a snackbar. In the real world,
                      // you'd often call a server or save the information in a database.
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Category Added',
                          ),
                          backgroundColor: Color(0xFF2E49FB),
                        ),
                      );
                    }
                    final name = nameEditingController.text;
                    if (name.isEmpty) {
                      return;
                    }
                    final type = selectCategoryNotifire.value;
                    final category = CategoryModel(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      type: type,
                      categoryName: name,
                    );

                    CategoryDb().insertCategory(category);
                    Navigator.of(ctx).pop();
                    // final snackBar = SnackBar(
                    //   elevation: 0,
                    //   behavior: SnackBarBehavior.floating,
                    //   backgroundColor: Colors.transparent,
                    //   content: AwesomeSnackbarContent(
                    //     title: 'On Snap!',
                    //     message: 'Category Add Successfully !',
                    //     contentType: ContentType.success,
                    //   ),
                    // );

                    // ScaffoldMessenger.of(context)
                    //   ..hideCurrentSnackBar()
                    //   ..showSnackBar(snackBar);
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
            )
          ],
        ),
      );
    },
  );
}

class RadioButton extends StatelessWidget {
  final String title;
  final CategoryType type;
  const RadioButton({
    super.key,
    required this.title,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ValueListenableBuilder(
            valueListenable: selectCategoryNotifire,
            builder: (BuildContext ctx, CategoryType newCategory, Widget? _) {
              return Radio<CategoryType>(
                fillColor: MaterialStateColor.resolveWith(
                    (states) => Color(0xFF2E49FB)),
                focusColor: MaterialStateColor.resolveWith(
                    (states) => Color.fromARGB(255, 255, 0, 0)),
                value: type,
                groupValue: newCategory,
                onChanged: (value) {
                  if (value == null) {
                    return;
                  }
                  selectCategoryNotifire.value = value;
                  selectCategoryNotifire.notifyListeners();
                },
              );
            }),
        Text(title),
      ],
    );
  }
}
