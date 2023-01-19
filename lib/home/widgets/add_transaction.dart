import 'package:animated_snack_bar/animated_snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:money_track/categories/category_app_popup.dart';

import 'package:money_track/db/category/db_category.dart';
import 'package:money_track/db/transaction/db_transaction_function.dart';
import 'package:money_track/models/categories_model/category_model.dart';
import 'package:money_track/models/transaction_model/transaction_model.dart';

class AddTransaction extends StatefulWidget {
  static const routeName = 'add-transaction';
  const AddTransaction({super.key});

  @override
  State<AddTransaction> createState() => _AddTransactionState();
}

class _AddTransactionState extends State<AddTransaction> {
  final _notesTextEditingController = TextEditingController();
  final _amountTextEditingController = TextEditingController();
  // final DatePickerController _controller = DatePickerController();
  bool _isVisibleCategoryId = false;
  bool _isVisibleDate = false;
  DateTime? _selectedDateTime;
  CategoryType? _selectedCategoryType;
  CategoryModel? _selectedCategoryModel;
  String? _categoryId;
  final _formKey = GlobalKey<FormState>();
  String _categoryItemValidationText = '';
  String _dateValidationText = '';
  int _value = 0;

  @override
  void initState() {
    _selectedCategoryType = CategoryType.income;
    super.initState();
  }

  //key for the form
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Add Transaction',
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                //income expense category selection is here
                selectCategoryType(),

                //category drop down button and add category button
                selectCategoryItem(context),
                const SizedBox(
                  height: 5,
                ),
                Visibility(
                  visible: _isVisibleCategoryId,
                  child: Padding(
                    padding: const EdgeInsets.all(3.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          '    Please Select Category',
                          style: const TextStyle(
                            color: Color.fromARGB(255, 192, 29, 17),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(
                  height: 5,
                ),

                TextFormField(
                  controller: _amountTextEditingController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Enter Amount';
                    }
                    return null;
                  },
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    hintText: 'Amount',
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        width: 1,
                      ), //<-- SEE HERE
                    ),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                TextFormField(
                  keyboardType: TextInputType.multiline,
                  controller: _notesTextEditingController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Enter the purpose';
                    }
                    return null;
                  },
                  decoration: const InputDecoration(
                    hintText: 'Notes',
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        width: 1,
                      ), //<-- SEE HERE
                    ),
                    border: OutlineInputBorder(),
                  ),
                  minLines: 5, // <-- SEE HERE
                  maxLines: 5,
                ),

                TextButton.icon(
                  onPressed: (() async {
                    final selectedTempDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now().subtract(
                          const Duration(
                            days: 30,
                          ),
                        ),
                        lastDate: DateTime.now(),
                        helpText: 'select a Date');
                    if (selectedTempDate == null) {
                      return;
                    } else {
                      setState(() {
                        _selectedDateTime = selectedTempDate;
                      });
                    }
                  }),
                  icon: const Icon(
                    Icons.calendar_today,
                  ),
                  label: Text(
                    _selectedDateTime == null
                        ? 'Select Your Date'
                        : parseDateTime(_selectedDateTime!),
                  ),
                ),
                const SizedBox(
                  height: 5,
                ),
                Visibility(
                  visible: _isVisibleDate,
                  child: const Padding(
                    padding: EdgeInsets.all(3.0),
                    child: Text(
                      'please Select Date',
                      style: TextStyle(
                        color: Color.fromARGB(255, 192, 29, 17),
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 5,
                ),

                // submit button
                ElevatedButton(
                  onPressed: (() {
                    if (_selectedDateTime == null) {
                      setState(() {
                        _isVisibleDate = true;
                      });
                    } else {
                      setState(() {
                        _isVisibleDate = false;
                      });
                    }
                    if (_categoryId == null) {
                      setState(() {
                        // _categoryItemValidationText =
                        //     '    Please Select Category';
                        _isVisibleCategoryId = true;
                      });
                    } else {
                      setState(() {
                        _isVisibleCategoryId = false;
                      });
                    }

                    if (_formKey.currentState!.validate()) {}
                    addTransaction();
                  }),
                  child: const Text(
                    'Submit',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Row selectCategoryItem(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            color: const Color(0xFFE9E8E8),
            border: Border.all(
              // color: Colors.black38,
              width: 1,
            ),
            borderRadius: BorderRadius.circular(5),
          ),
          child: Padding(
            padding: const EdgeInsets.only(left: 5, top: 5, bottom: 5),
            // CustomDropdown(
            //       hintText: 'Select job role',
            //       items: list,
            //       controller: jobRoleFormDropdownCtrl,
            //       excludeSelected: false,
            //     ),
            child: DropdownButton(
              // dropdownColor: Colors.amber,
              elevation: 9,

              // border: Border.all(color: Colors.redAccent, width: 2),
              hint: const Text('select category'),
              value: _categoryId,
              items: (_selectedCategoryType == CategoryType.income
                      ? CategoryDb.instance.incomeCategoryListListener
                      : CategoryDb.instance.expenseCategoryListListener)
                  .value
                  .map((e) {
                return DropdownMenuItem(
                  value: e.id,
                  child: Container(
                    decoration: BoxDecoration(
                      // border: Border.all(
                      //   // color: Colors.black38,
                      //   width: 1,
                      // ),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    width: 270,
                    child: Text(
                      e.categoryName,
                    ),
                  ),
                  onTap: () {
                    setState(() {
                      _selectedCategoryModel = e;
                    });
                  },
                );
              }).toList(),
              onChanged: ((selectedValue) {
                // print(selectedValue);
                setState(() {
                  _categoryId = selectedValue;
                });
              }),
            ),
          ),
        ),
        IconButton(
          onPressed: (() {
            showCategoryAddPopup(context);
          }),
          icon: const Icon(
            Icons.add_circle_outline,
            color: Color(0xFF2E49FB),
          ),
        ),
      ],
    );
  }

  Row selectCategoryType() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        ChoiceChip(
          padding: const EdgeInsets.all(8),
          label: const Text('Income'),
          // color of selected chip
          selectedColor: const Color(0xFF68AFF6),
          // selected chip value
          selected: _value == 0,
          // onSelected method
          onSelected: (bool selected) {
            setState(() {
              _value = 0;
              _selectedCategoryType = CategoryType.income;
              _categoryId = null;
            });
          },
        ),
        ChoiceChip(
          padding: const EdgeInsets.all(8),
          label: const Text('Expense'),
          // color of selected chip
          selectedColor: const Color(0xFFDE45FE),
          // selected chip value
          selected: _value == 1,
          // onSelected method
          onSelected: (bool selected) {
            setState(() {
              _value = 1;
              _selectedCategoryType = CategoryType.expense;
              _categoryId = null;
            });
          },
        ),
      ],
    );
  }

  Future addTransaction() async {
    final amountText = _amountTextEditingController.text;
    final notesText = _notesTextEditingController.text;
    if (amountText.isEmpty) {
      return;
    }
    //here we convert the amount text to double because amount should be number ,
    // using try parse if it is alphabets it will return null value
    final parsedAmount = double.tryParse(amountText);
    //to check the parsed amount is null or not
    if (parsedAmount == null) {
      return;
    }
    //to check the notes is null or not
    if (notesText.isEmpty) {
      return;
    }
    //here we checked category id because at initial category id is null
    if (_categoryId == null) {
      return;
    }
    // to check the selected date in null of not
    if (_selectedDateTime == null) {
      return;
    }
    // _categoryId;
    // _selectedCategoryType;
    final modal = TransactionModel(
      categoryModel: _selectedCategoryModel!,
      amount: parsedAmount,
      notes: notesText,
      date: _selectedDateTime!,
      type: _selectedCategoryType!,
    );

    TransactionDB.instance.addTransaction(modal);
    Navigator.of(context).pop();
    // ScaffoldMessenger.of(context).showSnackBar(
    //   SnackBar(
    //     elevation: 0,
    //     behavior: SnackBarBehavior.floating,
    //     backgroundColor: Colors.transparent,
    //     content: AwesomeSnackbarContent(
    //       title: 'On Snap!',
    //       message: 'Category Add Successfully !',
    //       contentType: ContentType.success,
    //     ),
    //   ),
    // );
    AnimatedSnackBar.rectangle(
      'Success',
      'Transaction Added Successfully',
      type: AnimatedSnackBarType.success,
      brightness: Brightness.light,
    ).show(
      context,
    );
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
  }

  String parseDateTime(DateTime date) {
    final dateFormatted = DateFormat.MMMMd().format(date);
    //using split we split the date into two parts
    final splitedDate = dateFormatted.split(' ');
    //here _splitedDate.last is second word that is month name and other one is the first word
    return "${splitedDate.last}  ${splitedDate.first} ";
  }
  // Call when you want to show the time picker
// final DateTime? newDate = await showDatePicker(
//                     context: context,
//                     initialDate: DateTime(2020, 11, 17),
//                     firstDate: DateTime(2017, 1),
//                     lastDate: DateTime(2022, 7),
//                     helpText: 'Select a date',
//                   );
}
