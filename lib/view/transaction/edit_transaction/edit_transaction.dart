import 'dart:developer';

import 'package:animated_snack_bar/animated_snack_bar.dart';
import 'package:flutter/material.dart';

import 'package:intl/intl.dart';
import 'package:money_track/controller/provider/add_transaction_provider.dart';
import 'package:money_track/controller/provider/category_provider.dart';
import 'package:money_track/controller/provider/transaction_provider.dart';
import 'package:money_track/core/colors.dart';

import 'package:money_track/models/categories_model/category_model.dart';
import 'package:money_track/models/transaction_model/transaction_model.dart';

import 'package:provider/provider.dart';

class EditTransaction extends StatelessWidget {
  EditTransaction({
    Key? key,
    required this.obj,
    this.id,
  }) : super(key: key);

  TextEditingController amountTextEditingController = TextEditingController();

  final String? id;
  TextEditingController notesTextEditingController = TextEditingController();
  final TransactionModel obj;

  final _formKey = GlobalKey<FormState>();
  bool isVisibleCategoryId = false;

//Edit Transaction Function
  Future<void> editTransaction(context) async {
    final amountText = amountTextEditingController.text;
    final notesText = notesTextEditingController.text;
    if (amountText.isEmpty) {
      return;
    }
    //here we convert the amount text to double because amount should be number ,
    // using try parse if it is alphabets it will return null value
    final parsedAmount = double.tryParse(amountText);
    //to check the parsed amount is null or not
    if (parsedAmount == null) {
      log('$parsedAmount null value');
      return;
    }
    //to check the notes is null or not
    // if (notesText.isEmpty) {
    //   return;
    // }
    //here we checked category id because at initial category id is null
    if (Provider.of<AddTransactionProvider>(context, listen: false)
            .categoryId ==
        null) {
      return;
    }
    // to check the selected date in null of not
    // if (Provider.of<AddTransactionProvider>(context, listen: false)
    //         .selectedDateTime ==
    //     null) {
    //   return;
    // }

    if (Provider.of<AddTransactionProvider>(context, listen: false)
            .selectedCategoryType ==
        null) {
      return;
    }
    // categoryId;
    // selectedCategoryType;
    final modal = TransactionModel(
      categoryModel: Provider.of<AddTransactionProvider>(context, listen: false)
          .selectedCategoryModel!,
      amount: parsedAmount,
      notes: notesText,
      date: Provider.of<AddTransactionProvider>(context, listen: false)
          .selectedDateTime,
      type: Provider.of<AddTransactionProvider>(context, listen: false)
          .selectedCategoryType!,
      id: obj.id,
    );

    // TransactionDB.instance.editTransaction(modal);
    await Provider.of<ProviderTransaction>(context, listen: false)
        .editTransaction(modal);
    // Provider.of<ProviderTransaction>(context, listen: false).refreshUi();
    Navigator.of(context).pop();

    // TransactionDB.instance.refreshUi();

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

  @override
  Widget build(BuildContext context) {
    Provider.of<AddTransactionProvider>(context, listen: false).categoryId =
        obj.categoryModel.id;
    amountTextEditingController =
        TextEditingController(text: obj.amount.toString());
    notesTextEditingController = TextEditingController(text: obj.notes);
    Provider.of<AddTransactionProvider>(context, listen: false)
        .selectedDateTime = obj.date;
    Provider.of<AddTransactionProvider>(context, listen: false)
        .selectedCategoryType = obj.type;
    Provider.of<AddTransactionProvider>(context, listen: false)
        .selectedCategoryModel = obj.categoryModel;
    // final size = MediaQuery.of(context).size;
    Provider.of<AddTransactionProvider>(context, listen: false).value =
        obj.type.index;

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
                    Consumer<AddTransactionProvider>(
                        builder: (context, provider, child) {
                      return ChoiceChip(
                        padding: const EdgeInsets.all(8),
                        label: const Text('Income'),
                        // color of selected chip
                        selectedColor: const Color(0xFF68AFF6),
                        // selected chip value
                        selected: provider.value == 0,
                        // onSelected method
                        onSelected: (bool selected) {
                          provider.incomeChoiceChip();
                          // setState(() {
                          //   value = 0;
                          //   selectedCategoryType = CategoryType.income;
                          //   categoryId = null;
                          // });
                        },
                      );
                    }),
                    const SizedBox(
                      width: 20,
                    ),
                    Consumer<AddTransactionProvider>(
                        builder: (context, provider, child) {
                      return ChoiceChip(
                        padding: const EdgeInsets.all(8),
                        label: const Text('Expense'),
                        // color of selected chip
                        selectedColor: const Color(0xFFDE45FE),
                        // selected chip value
                        selected: provider.value == 1,
                        // onSelected method
                        onSelected: (bool selected) {
                          provider.expenseChoiceChip();
                          // setState(() {
                          //   value = 1;
                          //   selectedCategoryType = CategoryType.expense;
                          //   categoryId = null;
                          // });
                        },
                      );
                    }),
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
              Consumer2<AddTransactionProvider, CategoryProvider>(
                  builder: (context, tProvider, cProvider, child) {
                return DropdownButtonFormField(
                  decoration: const InputDecoration(
                      border: OutlineInputBorder(
                    borderSide: BorderSide(
                      width: 1,
                    ),
                  )),

                  elevation: 9,

                  // border: Border.all(color: Colors.redAccent, width: 2),
                  hint: const Text('Select the Category'),
                  value: tProvider.categoryId,
                  items: (tProvider.selectedCategoryType == CategoryType.income
                          ? cProvider.incomeCategoryProvider
                          : cProvider.expenseCategoryProvider)
                      .map((e) {
                    return DropdownMenuItem(
                      value: e.id,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                        ),
                        width: 220,
                        child: Text(
                          e.categoryName,
                        ),
                      ),
                      onTap: () {
                        context.read<CategoryProvider>().refreshUI();
                        tProvider.selectedCategoryModel = e;
                        log('$e');
                      },
                    );
                  }).toList(),
                  onChanged: ((selectedValue) {
                    // print(selectedValue);

                    // cProvider.refreshUI();
                    tProvider.categoryId = selectedValue;
                  }),
                );
              }),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Visibility(
                  visible: isVisibleCategoryId,
                  child: const Padding(
                    padding: EdgeInsets.all(3.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
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
                  controller: amountTextEditingController,
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
              Consumer<AddTransactionProvider>(
                  builder: (context, value, child) {
                return TextButton(
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
                    value.dateSelection(selectedTempDate);
                  }),
                  style: ElevatedButton.styleFrom(
                    side: const BorderSide(width: 1.0),
                    // backgroundColor: themeDarkBlue,
                    foregroundColor: themeDarkBlue,
                    // primary: Colors.black,
                    minimumSize: const Size.fromHeight(50),
                  ),
                  child: Text(parseDateTime(value.selectedDateTime)),
                );
              }),
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
                  controller: notesTextEditingController,
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
              const SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: (() {
                      // if (categoryId == null) {
                      //   setState(() {
                      //     // _categoryItemValidationText =
                      //     //     '    Please Select Category';
                      //     isVisibleCategoryId = true;
                      //   });
                      // } else {
                      //   setState(() {
                      //     isVisibleCategoryId = false;
                      //   });
                      // }

                      if (_formKey.currentState!.validate()) {
                        editTransaction(context);
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
}
