import 'dart:developer';

import 'package:animated_snack_bar/animated_snack_bar.dart';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:money_track/provider/add_transaction_provider.dart';
import 'package:money_track/provider/category_provider.dart';
import 'package:money_track/provider/transaction_provider.dart';

import 'package:money_track/view/categories/widgets/category_type_pop_up.dart';
import 'package:money_track/core/constants/colors.dart';

import 'package:money_track/models/categories_model/category_model.dart';
import 'package:money_track/models/transaction_model/transaction_model.dart';

import 'package:provider/provider.dart';

class AddTransaction extends StatelessWidget {
  AddTransaction({super.key});

  static const routeName = 'add-transaction';

  // final DatePickerController _controller = DatePickerController();
  final bool isVisibleDate = false;

  final _amountTextEditingController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  final _notesTextEditingController = TextEditingController();

  Row selectCategoryItem(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(child: Consumer2<AddTransactionProvider, CategoryProvider>(
          builder: (context, tProvider, cProvider, child) {
            return DropdownButtonFormField(
              alignment: Alignment.bottomLeft,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Required';
                }
                return null;
              },
              decoration: InputDecoration(
                errorBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.red, width: 1),
                ),
                enabledBorder: const OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide:
                      BorderSide(color: ColorConstants.themeColor, width: 2),
                ),
              ),
              elevation: 9,
              hint: const Text('select category'),
              value: tProvider.categoryId,
              items: (tProvider.selectedCategoryType == CategoryType.income
                      ? cProvider.incomeCategoryProvider
                      : cProvider.expenseCategoryProvider)
                  .map((e) {
                return DropdownMenuItem(
                  alignment: AlignmentDirectional.centerStart,
                  value: e.id,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Text(
                      e.categoryName,
                    ),
                  ),
                  onTap: () {
                    // CategoryDb.instance.refreshUI();
                    context.read<CategoryProvider>().refreshUI();
                    tProvider.selectedCategoryModel = e;
                  },
                );
              }).toList(),
              onChanged: ((selectedValue) {
                // print(selectedValue);
                tProvider.categoryId = selectedValue;
              }),
            );
          },
        )),
        Padding(
          padding: const EdgeInsets.only(left: 10),
          child: Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: ColorConstants.themeColor),
            child: IconButton(
              onPressed: (() {
                // showCategoryAddPopup(context);
                categoryTypePopUp(
                    context,
                    context
                        .read<AddTransactionProvider>()
                        .selectedCategoryType!);
                context.read<CategoryProvider>().expenseCategoryProvider;
                context.read<CategoryProvider>().incomeCategoryProvider;

                // CategoryDb.instance.expenseCategoryListListener
                //     .notifyListeners();
                // CategoryDb.instance.incomeCategoryListListener
                //     .notifyListeners();
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
        Consumer<AddTransactionProvider>(builder: (context, provider, child) {
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
            },
          );
        }),
        const SizedBox(
          width: 20,
        ),
        Consumer<AddTransactionProvider>(builder: (context, provider, child) {
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
            },
          );
        }),
      ],
    );
  }

  //*Add Transaction Function
  String parseDateTime(DateTime date) {
    final dateFormatted = DateFormat.MMMMd().format(date);
    //using split we split the date into two parts
    final splitedDate = dateFormatted.split(' ');
    //here _splitedDate.last is second word that is month name and other one is the first word
    return "${splitedDate.last}  ${splitedDate.first} ";
  }

  //key for the form
  @override
  Widget build(BuildContext context) {
    // CategoryDb.instance.refreshUI();
    context.read<ProviderTransaction>().refreshUi();
    context.read<CategoryProvider>().refreshUI();
    // TransactionDB.instance.refreshUi();
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

                // * category drop down button and add category button
                selectCategoryItem(context),

                const SizedBox(
                  height: 5,
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Visibility(
                    visible: false,
                    child: Padding(
                      padding: EdgeInsets.all(3.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
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
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 0, vertical: 10),
                  child: Center(
                    child: Consumer<AddTransactionProvider>(
                        builder: (context, value, child) {
                      return TextButton(
                        style: ElevatedButton.styleFrom(
                          side: const BorderSide(width: 1.0),
                          // backgroundColor:ColorConstants. themeColor,
                          foregroundColor: ColorConstants.themeColor,
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
                          value.dateSelection(selectedTempDate);
                        }),
                        child: Text(
                          value.selectedDateTime == null
                              // ? 'Select Date'
                              ? parseDateTime(DateTime.now())
                              : parseDateTime(context
                                  .read<AddTransactionProvider>()
                                  .selectedDateTime),
                        ),
                      );
                    }),
                  ),
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

                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: Visibility(
                    visible: isVisibleDate,
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: (() {
                        if (_formKey.currentState!.validate()) {
                          addTransaction(context);
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
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future addTransaction(context) async {
    final amountText = _amountTextEditingController.text;
    final notesText = _notesTextEditingController.text;
    if (amountText.isEmpty) {
      log("amount null");
      return;
    }
    //here we convert the amount text to double because amount should be number ,
    // using try parse if it is alphabets it will return null value
    final parsedAmount = double.tryParse(amountText);
    //to check the parsed amount is null or not

    log("$parsedAmount is added");
    if (parsedAmount == null) {
      log("amount null");
      return;
    }
    //to check the notes is null or not
    // if (notesText.isEmpty) {
    //   return;
    // }
    //here we checked category id because at initial category id is null
    // Provider.of<AddTransactionProvider>(context, listen: false).categoryId;
    if (Provider.of<AddTransactionProvider>(context, listen: false)
            .categoryId ==
        null) {
      log("category id null");
      return;
    }
    log('${Provider.of<AddTransactionProvider>(context, listen: false).categoryId}');
    final modal = TransactionModel(
      amount: parsedAmount,
      date: Provider.of<AddTransactionProvider>(context, listen: false)
          .selectedDateTime,
      type: Provider.of<AddTransactionProvider>(context, listen: false)
          .selectedCategoryType!,
      categoryModel: Provider.of<AddTransactionProvider>(context, listen: false)
          .selectedCategoryModel!,
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      notes: notesText,
    );

    // TransactionDB.instance.addTransaction(modal);
    await Provider.of<ProviderTransaction>(context, listen: false)
        .addTransaction(modal);
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
}
