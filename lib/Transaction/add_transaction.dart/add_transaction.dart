import 'package:animated_snack_bar/animated_snack_bar.dart';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:money_track/categories/category_app_popup.dart';
import 'package:money_track/categories/category_type_pop_up.dart';
import 'package:money_track/constants/color/colors.dart';

import 'package:money_track/db/category/db_category.dart';
import 'package:money_track/db/transaction/db_transaction_function.dart';
import 'package:money_track/models/categories_model/category_model.dart';
import 'package:money_track/models/transaction_model/transaction_model.dart';

class AddTransaction extends StatefulWidget {
  const AddTransaction({super.key});

  static const routeName = 'add-transaction';

  @override
  State<AddTransaction> createState() => _AddTransactionState();
}

class _AddTransactionState extends State<AddTransaction> {
  final _amountTextEditingController = TextEditingController();
  String? _categoryId;
  final _formKey = GlobalKey<FormState>();
  // final DatePickerController _controller = DatePickerController();
  bool _isVisibleCategoryId = false;

  bool _isVisibleDate = false;
  final _notesTextEditingController = TextEditingController();
  CategoryModel? _selectedCategoryModel;
  CategoryType? _selectedCategoryType;
  DateTime? _selectedDateTime;
  int _value = 0;

  @override
  void initState() {
    _selectedCategoryType = CategoryType.income;
    super.initState();
  }

  //key for the form
  @override
  Widget build(BuildContext context) {
    CategoryDb.instance.refreshUI();
    TransactionDB.instance.refreshUi();
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                //income expense category selection is here
                selectCategoryType(),
                const SizedBox(
                  height: 10,
                ),
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    'Category',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                //category drop down button and add category button
                selectCategoryItem(context),

                const SizedBox(
                  height: 5,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Visibility(
                    visible: false,
                    child: Padding(
                      padding: const EdgeInsets.all(3.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: const [
                          Text(
                            '    Please Select the Category',
                            style: TextStyle(
                              color: Color.fromARGB(255, 192, 29, 17),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    'Amount',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                TextFormField(
                  maxLength: 7,
                  controller: _amountTextEditingController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Required';
                    }
                    return null;
                  },
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    hintText: 'Enter the Amount',
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
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    'Notes',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                TextFormField(
                  keyboardType: TextInputType.multiline,
                  controller: _notesTextEditingController,
                  // validator: (value) {
                  //   if (value == null || value.isEmpty) {
                  //     return 'Enter the purpose';
                  //   }
                  //   return null;
                  // },
                  decoration: const InputDecoration(
                    hintText: 'Enter the Purpose',
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

                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 0, vertical: 10),
                  child: Center(
                    child: TextButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: themeDarkBlue,
                        foregroundColor: Colors.white,
                        // primary: Colors.black,
                        minimumSize: const Size.fromHeight(50), // NEW
                      ),
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
                          setState(() {
                            _selectedDateTime = DateTime.now();
                          });
                        } else {
                          setState(() {
                            _selectedDateTime = selectedTempDate;
                          });
                        }
                      }),
                      // icon: const Icon(
                      //   Icons.calendar_today,
                      // ),
                      child: Text(
                        _selectedDateTime == null
                            // ? 'Select Date'
                            ? parseDateTime(DateTime.now())
                            : parseDateTime(_selectedDateTime!),
                      ),
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: Visibility(
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
                ),

                // submit button
                ElevatedButton(
                  onPressed: (() {
                    if (_selectedDateTime == null) {
                      setState(() {
                        _selectedDateTime = DateTime.now();
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

                    if (_formKey.currentState!.validate()) {
                      addTransaction();
                    }
                  }),
                  style: ElevatedButton.styleFrom(
                    shape: const StadiumBorder(),
                  ),
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
        Expanded(
            child: ValueListenableBuilder(
          valueListenable: _selectedCategoryType == CategoryType.income
              ? CategoryDb().incomeCategoryListListener
              : CategoryDb().expenseCategoryListListener,
          builder: (BuildContext context, dynamic value, Widget? child) {
            return DropdownButtonFormField(
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Required';
                }
                return null;
              },
              decoration: const InputDecoration(
                errorBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.red, width: 1),
                ),
                enabledBorder: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: themeDarkBlue, width: 2),
                ),
              ),
              elevation: 9,
              hint: const Text('select category'),
              value: _categoryId,
              items: (_selectedCategoryType == CategoryType.income
                      ? CategoryDb.instance.incomeCategoryListListener
                      : CategoryDb.instance.expenseCategoryListListener)
                  .value
                  .map((e) {
                return DropdownMenuItem(
                  alignment: AlignmentDirectional.center,
                  value: e.id,
                  child: Container(
                    decoration: BoxDecoration(
                      // border: Border.all(
                      //   color: Colors.black38,
                      //   width: 1,
                      // ),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Text(
                      e.categoryName,
                    ),
                  ),
                  onTap: () {
                    setState(() {
                      CategoryDb.instance.refreshUI();
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
            );
          },
        )),
        Padding(
          padding: const EdgeInsets.only(left: 10),
          child: Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10), color: themeDarkBlue),
            child: IconButton(
              onPressed: (() {
                // showCategoryAddPopup(context);
                categoryTypePopUp(context, _selectedCategoryType!);
                CategoryDb.instance.expenseCategoryListListener
                    .notifyListeners();
                CategoryDb.instance.incomeCategoryListListener
                    .notifyListeners();
              }),
              icon: const Icon(
                Icons.add_circle_outline,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }
  //*Select Category Type

  Row selectCategoryType() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
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
        const SizedBox(
          width: 20,
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

  //*Add Transaction Function

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
    // if (notesText.isEmpty) {
    //   return;
    // }
    //here we checked category id because at initial category id is null
    if (_categoryId == null) {
      return;
    }
    // to check the selected date in null of not
    if (_selectedDateTime == null) {
      return;
    }

    final modal = TransactionModel(
      amount: parsedAmount,
      date: _selectedDateTime!,
      type: _selectedCategoryType!,
      categoryModel: _selectedCategoryModel!,
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      notes: notesText,
    );

    TransactionDB.instance.addTransaction(modal);
    Navigator.of(context).pop();

    AnimatedSnackBar.rectangle(
      'Success',
      'Transaction Added Successfully',
      type: AnimatedSnackBarType.success,
      brightness: Brightness.light,
      duration: const Duration(
        seconds: 3,
      ),
    ).show(
      context,
    );
  }

  String parseDateTime(DateTime date) {
    final dateFormatted = DateFormat.MMMMd().format(date);
    //using split we split the date into two parts
    final splitedDate = dateFormatted.split(' ');
    //here _splitedDate.last is second word that is month name and other one is the first word
    return "${splitedDate.last}  ${splitedDate.first} ";
  }
}
