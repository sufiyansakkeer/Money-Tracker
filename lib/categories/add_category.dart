import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:money_track/db/category/db_category.dart';

import '../models/categories_model/category_model.dart';

const double fabSize = 56;

//every changes that happen in the radio icon (that is the circle ),
//that will store in this selected Category notifier,
// using value listenable builder we can change the state of the widget (her it is row)
ValueNotifier<CategoryType> selectedCategoryNotifier =
    ValueNotifier(CategoryType.income);

class CustomCategoriesWidget extends StatelessWidget {
  const CustomCategoriesWidget({super.key});

  // final ContainerTransitionType transitionType;

  @override
  Widget build(BuildContext context) => OpenContainer(
        transitionDuration: const Duration(milliseconds: 500),
        openBuilder: (context, _) => const AddCategory(),
        closedShape: const CircleBorder(),
        closedColor: Theme.of(context).primaryColor,
        closedBuilder: (context, openContainer) => Container(
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
          ),
          height: fabSize,
          width: fabSize,
          child: const Icon(
            Icons.add,
            color: Color(0xFF2E49FB),
          ),
        ),
      );
}

class AddCategory extends StatefulWidget {
  const AddCategory({super.key});

  @override
  State<AddCategory> createState() => _AddCategoryState();
}

class _AddCategoryState extends State<AddCategory> {
  final _nameEditingCategory = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: const Text('add category'),
      ),
      body: Padding(
        padding: const EdgeInsets.only(
          top: 50,
          left: 10,
          right: 10,
          bottom: 10,
        ),
        child: Column(
          children: [
            // DropdownButton<String>(
            //   focusColor: Colors.white,
            //   value: _chosenValue,
            //   //elevation: 5,
            //   style: const TextStyle(color: Color.fromARGB(255, 64, 55, 245)),
            //   iconEnabledColor: Colors.black,
            //   items: <String>[
            //     'Income',
            //     'Expense',
            //   ].map<DropdownMenuItem<String>>((String value) {
            //     return DropdownMenuItem<String>(
            //       value: value,
            //       child: Text(
            //         value,
            //         style: const TextStyle(color: Colors.black),
            //       ),
            //     );
            //   }).toList(),
            //   hint: const Text(
            //     "Please Select the Category",
            //     style: TextStyle(
            //         color: Colors.black,
            //         fontSize: 14,
            //         fontWeight: FontWeight.w500),
            //   ),
            //   onChanged: (String? value) {
            //     setState(() {
            //       _chosenValue = value;
            //     });
            //   },
            // ),
            Row(
              children: const [
                RadioButton(
                  'Income',
                  CategoryType.income,
                ),
                RadioButton(
                  'Expense',
                  CategoryType.expense,
                ),
              ],
            ),

            TextFormField(
              //here name editing category will hold the data in the text form field
              controller: _nameEditingCategory,
            ),
            ElevatedButton(
              onPressed: (() {
                //her we convert the text in the text form field into the variable as string format
                final name = _nameEditingCategory.text.trim();
                if (name.isEmpty) {
                  return;
                }
                //here we assigning the bool value in the selected category notifier ,
                //because it hold the category type which income or expense
                final categoryType = selectedCategoryNotifier;
                //Category Name is the class we created for the model, in that 3 required parameters is passing ,
                //here we are creating an object for the category name
                final categoryModel = CategoryModel(
                  categoryName: name,
                  id: DateTime.fromMicrosecondsSinceEpoch.toString(),
                  type: categoryType.value,
                );
                //here we created an object for the category model
                //and we inserted the object into the category database through insertCategory function
                CategoryDb.instance.insertCategory(categoryModel);
                // CategoryDB().refreshUI();
                // print(_categoryModel);
                Navigator.of(context).pop();
              }),
              child: const Text(
                'submit',
              ),
            ),
          ],
        ),
      ),
    );
  }

  // void dropDownCallBack(String? selectedValue) {
  //   if (selectedValue is String) {
  //     setState(() {
  //       var _dropDownValue = selectedValue;
  //     });
  //   }
  // }
}

class RadioButton extends StatelessWidget {
  final String title;
  final CategoryType type;

  const RadioButton(this.title, this.type, {super.key});

  @override
  Widget build(Object context) {
    return Row(
      children: [
        //here we use value listenable builder to the radio button only,
        // because we only need to change the button only not the text that next to the radio button,
        // using value listener we can select which listener should we access
        ValueListenableBuilder(
          //each time the value listenable change ,it will build new radio button
          builder: (BuildContext context, newCategory, Widget? child) {
            return Radio(
              value: type,
              //here group value will decide what category value should hold
              groupValue: newCategory,
              onChanged: ((value) {
                if (value == null) {
                  return;
                }
                selectedCategoryNotifier.value = value;
                selectedCategoryNotifier.notifyListeners();
              }),
            );
          },
          valueListenable: selectedCategoryNotifier,
        ),
        Text(
          title,
        ),
      ],
    );
  }
}
