import 'package:animated_snack_bar/animated_snack_bar.dart';
import 'package:flutter/material.dart';

import 'package:intl/intl.dart';

import 'package:money_track/db/category/db_category.dart';
import 'package:money_track/db/transaction/db_transaction_function.dart';
import 'package:money_track/models/categories_model/category_model.dart';
import 'package:money_track/models/transaction_model/transaction_model.dart';

import '../../constants/color/colors.dart';

class EditTransaction extends StatefulWidget {
  const EditTransaction({
    Key? key,
    required this.obj,
    this.id,
  }) : super(key: key);

  final String? id;
  final TransactionModel obj;

  @override
  State<EditTransaction> createState() => _EditTransactionState();
}

class _EditTransactionState extends State<EditTransaction> {
  TextEditingController _amountTextEditingController = TextEditingController();
  String? _categoryId;
  final _formKey = GlobalKey<FormState>();
  bool _isVisibleCategoryId = false;
  TextEditingController _notesTextEditingController = TextEditingController();
  CategoryModel? _selectedCategoryModel;
  CategoryType? _selectedCategoryType;
  DateTime? _selectedDateTime;
  int _value = 0;

  @override
  void initState() {
    super.initState();

    _value = widget.obj.type.index;
    _categoryId = widget.obj.categoryModel.id;
    _amountTextEditingController =
        TextEditingController(text: widget.obj.amount.toString());
    _notesTextEditingController = TextEditingController(text: widget.obj.notes);
    _selectedDateTime = widget.obj.date;
    _selectedCategoryType = widget.obj.type;
    _selectedCategoryModel = widget.obj.categoryModel;
  }

  @override
  Widget build(BuildContext context) {
    // final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Update'),
      ),
      body: SingleChildScrollView(
          child: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Row(
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
                    SizedBox(
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
                ),
              ),
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
              DropdownButtonFormField(
                decoration: const InputDecoration(
                    border: OutlineInputBorder(
                  borderSide: BorderSide(
                    width: 1,
                  ),
                )),

                elevation: 9,

                // border: Border.all(color: Colors.redAccent, width: 2),
                hint: const Text('Select the Category'),
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
                      width: 220,
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
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Visibility(
                  visible: _isVisibleCategoryId,
                  child: Padding(
                    padding: const EdgeInsets.all(3.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: const [
                        Text(
                          '  Please Select Category',
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
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: TextFormField(
                  controller: _amountTextEditingController,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Enter Amount';
                    }
                    return null;
                  },
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
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: TextFormField(
                  keyboardType: TextInputType.multiline,
                  controller: _notesTextEditingController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Enter your purpose';
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
              ),
              TextButton(
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
                style: ElevatedButton.styleFrom(
                  backgroundColor: themeDarkBlue,
                  foregroundColor: Colors.white,
                  // primary: Colors.black,
                  minimumSize: const Size.fromHeight(50), // NEW
                ),
                child: Text(
                  _selectedDateTime == null
                      ? 'Select Your Date'
                      : parseDateTime(_selectedDateTime!),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: (() {
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
                        editTransaction();
                      }
                    }),
                    style: ElevatedButton.styleFrom(
                      shape: const StadiumBorder(),
                    ),
                    child: const Text(
                      'Update',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      )),
    );
  }
//Edit Transaction Function

  Future<void> editTransaction() async {
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

    if (_selectedCategoryType == null) {
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
      id: widget.obj.id,
    );

    TransactionDB.instance.editTransaction(modal);
    Navigator.of(context).pop();
    TransactionDB.instance.refreshUi();

    AnimatedSnackBar.rectangle(
      'Success',
      'Updated Successfully',
      type: AnimatedSnackBarType.success,
      brightness: Brightness.light,
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
