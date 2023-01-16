import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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

  DateTime? _selectedDateTime;
  CategoryType? _selectedCategoryType;
  CategoryModel? _selectedCategoryModel;
  String? _categoryId;

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
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              TextFormField(
                controller: _amountTextEditingController,
                // validator: (value) {
                //   if (value == null || value.isEmpty) {
                //     return 'Enter Amount';
                //   }
                //   return null;
                // },
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  hintText: 'Amount',
                ),
              ),
              TextFormField(
                controller: _notesTextEditingController,
                decoration: const InputDecoration(
                  hintText: 'Notes',
                ),
              ),
              //date of the transaction
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
                  );
                  if (selectedTempDate == null) {
                    return;
                  } else {
                    print(selectedTempDate);
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Row(
                    children: [
                      // RadioButton('Income', CategoryType.income),
                      Radio(
                        // value is what the radio button is holding
                        value: CategoryType.income,
                        //user selected value is group value ,
                        groupValue: _selectedCategoryType,
                        onChanged: ((value) {
                          setState(() {
                            _selectedCategoryType = CategoryType.income;
                            _categoryId = null;
                          });
                        }),
                      ),
                      const Text(
                        'Income',
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      // RadioButton('Expense', CategoryType.expense),
                      Radio(
                        value: CategoryType.expense,
                        groupValue: _selectedCategoryType,
                        onChanged: ((value) {
                          setState(() {
                            _selectedCategoryType = CategoryType.expense;
                            _categoryId = null;
                          });
                        }),
                      ),
                      const Text(
                        'Expense',
                      ),
                    ],
                  ),
                ],
              ),
              //category drop down button
              DropdownButton(
                hint: const Text('select category'),
                value: _categoryId,
                items: (_selectedCategoryType == CategoryType.income
                        ? CategoryDb.instance.incomeCategoryListListener
                        : CategoryDb.instance.expenseCategoryListListener)
                    .value
                    .map((e) {
                  return DropdownMenuItem(
                    value: e.id,
                    child: Text(
                      e.categoryName,
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
              // DropdownButton(
              //   hint: const Text('Select Category'),
              //   items: CategoryDb.instance.incomeCategoryListListener.value
              //       .map((e) {
              //     return DropdownMenuItem(
              //       value: e.id,
              //       child: Text(e.categoryName),
              //     );
              //   }).toList(),
              //   onChanged: ((selectedValue) {
              //     print(selectedValue);
              //   }),
              // ),

              // submit button
              ElevatedButton(
                onPressed: (() {
                  addTransaction();
                  // if (_formKey.currentState!.validate()) {
                  //   // If the form is valid, display a snackbar. In the real world,
                  //   // you'd often call a server or save the information in a database.
                  //   ScaffoldMessenger.of(context).showSnackBar(
                  //     const SnackBar(
                  //       content: Text(
                  //         'Category Added',
                  //       ),
                  //       backgroundColor: Color(0xFF2E49FB),
                  //     ),
                  //   );
                  // }
                }),
                child: const Text(
                  'Submit',
                ),
              ),
            ],
          ),
        ),
      ),
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
}
