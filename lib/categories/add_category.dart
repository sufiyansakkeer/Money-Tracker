import 'package:animations/animations.dart';
import 'package:flutter/material.dart';

const double fabSize = 56;

class CustomCategoriesWidget extends StatelessWidget {
  const CustomCategoriesWidget({super.key});

  // final ContainerTransitionType transitionType;

  @override
  Widget build(BuildContext context) => OpenContainer(
        transitionDuration: const Duration(milliseconds: 500),
        openBuilder: (context, _) => AddCategory(),
        closedShape: const CircleBorder(),
        closedColor: Theme.of(context).primaryColor,
        closedBuilder: (context, openContainer) => Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Theme.of(context).primaryColor,
          ),
          height: fabSize,
          width: fabSize,
          child: const Icon(
            Icons.add,
            color: Colors.white,
          ),
        ),
      );
}

class AddCategory extends StatefulWidget {
  AddCategory({super.key});

  @override
  State<AddCategory> createState() => _AddCategoryState();
}

class _AddCategoryState extends State<AddCategory> {
  String? _chosenValue;
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
            TextFormField(),
            ElevatedButton(
              onPressed: (() {}),
              child: const Text(
                'submit',
              ),
            ),
          ],
        ),
      ),
    );
  }

  void dropDownCallBack(String? selectedValue) {
    if (selectedValue is String) {
      setState(() {
        var _dropDownValue = selectedValue;
      });
    }
  }
}
