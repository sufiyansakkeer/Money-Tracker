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

  DateTime? _selectedDateTime;
  CategoryType? _selectedCategoryType;
  CategoryModel? _selectedCategoryModel;
  String? _categoryId;
  final _formKey = GlobalKey<FormState>();
  String _categoryItemValidationText = '';
  String _dateValidationText = '';

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
                selectCategoryType(),
                //category drop down button and add category button
                selectCategoryItem(context),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      _categoryItemValidationText,
                      style: const TextStyle(
                        color: Color.fromARGB(255, 192, 29, 17),
                        fontSize: 12,
                      ),
                    ),
                  ],
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
                Text(
                  _dateValidationText,
                  style: const TextStyle(
                    color: Color.fromARGB(255, 192, 29, 17),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),

                // submit button
                ElevatedButton(
                  onPressed: (() {
                    if (_selectedDateTime == null) {
                      setState(() {
                        _dateValidationText = 'please Select Date';
                      });
                    } else {
                      setState(() {
                        _dateValidationText = '';
                      });
                    }
                    if (_categoryId == null) {
                      setState(() {
                        _categoryItemValidationText = 'Please Select Category';
                      });
                    } else {
                      _categoryItemValidationText = '';
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
            border: Border.all(
              // color: Colors.black38,
              width: 1,
            ),
            borderRadius: BorderRadius.circular(5),
          ),
          child: Padding(
            padding: const EdgeInsets.only(left: 5, top: 5, bottom: 5),
            child: DropdownButton(
              dropdownColor: Colors.amber,
              elevation: 0,

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
                      border: Border.all(
                        // color: Colors.black38,
                        width: 1,
                      ),
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
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Row(
          children: [
            //   OutlineButton(
            //   onPressed: () {
            //     setState(() {
            //       value = index;
            //     });
            //   },
            //   child: Text(
            //     text,
            //     style: TextStyle(
            //       color: (value == index) ? Colors.green : Colors.black,
            //     ),
            //   ),
            //   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            //   borderSide:
            //       BorderSide(color: (value == index) ? Colors.green : Colors.black),
            // );// RadioButton('Income', CategoryType.income),
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
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Transaction Added',
        ),
        backgroundColor: Color(0xFF2E49FB),
      ),
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
}
