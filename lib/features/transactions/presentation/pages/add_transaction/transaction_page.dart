import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:money_track/core/constants/colors.dart';
import 'package:money_track/core/constants/style_constants.dart';
import 'package:money_track/core/utils/currency_formatter.dart';
import 'package:money_track/core/utils/navigation_extension.dart';
import 'package:money_track/core/utils/sized_box_extension.dart';
import 'package:money_track/core/utils/snack_bar_extension.dart';
import 'package:money_track/core/utils/widget_extension.dart';
import 'package:money_track/domain/entities/category_entity.dart';
import 'package:money_track/domain/entities/transaction_entity.dart';
import 'package:money_track/features/budget/presentation/bloc/budget_bloc.dart';
import 'package:money_track/features/categories/presentation/bloc/category_bloc.dart';
import 'package:money_track/features/transactions/presentation/bloc/transaction_bloc.dart';
import 'package:money_track/features/transactions/presentation/bloc/total_transaction/total_transaction_cubit.dart';
import 'package:money_track/core/widgets/category_icon_widget.dart';
import 'package:money_track/core/widgets/custom_inkwell.dart';
import 'package:svg_flutter/svg.dart';

class TransactionPage extends StatefulWidget {
  const TransactionPage(
      {super.key, required this.isExpense, this.transactionEntity});

  final bool isExpense;
  final TransactionEntity? transactionEntity;

  @override
  State<TransactionPage> createState() => _TransactionPageState();
}

class _TransactionPageState extends State<TransactionPage> {
  late TextEditingController amountEditingController;
  late TextEditingController categoryController;
  late TextEditingController descriptionController;
  late TextEditingController dateController;
  CategoryType? categoryType;
  CategoryEntity? categoryEntity;
  DateTime date = DateTime.now();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    amountEditingController = TextEditingController();
    categoryController = TextEditingController();
    descriptionController = TextEditingController();
    dateController = TextEditingController();

    if (widget.transactionEntity != null) {
      categoryEntity = widget.transactionEntity!.category;
      categoryType = widget.transactionEntity!.categoryType;
      date = widget.transactionEntity!.date;
      amountEditingController.text =
          widget.transactionEntity!.amount.toString();
      categoryController.text = widget.transactionEntity!.category.categoryName;
      descriptionController.text = widget.transactionEntity!.notes ?? "";
      dateController.text = DateFormat('dd-MMMM-yyyy').format(date);
    }

    super.initState();
  }

  @override
  void dispose() {
    amountEditingController.dispose();
    categoryController.dispose();
    descriptionController.dispose();
    dateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.isExpense
          ? ColorConstants.expenseColor
          : ColorConstants.incomeColor,
      appBar: PreferredSize(
        preferredSize: const Size(double.infinity, 50),
        child: SafeArea(
          child: Container(
            color: widget.isExpense
                ? ColorConstants.expenseColor
                : ColorConstants.incomeColor,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  InkWell(
                    onTap: () => context.pop(),
                    child: SvgPicture.asset(
                      "assets/svg/common/arrow_left_white.svg",
                      height: 20,
                    ),
                  ),
                  const Spacer(),
                  Center(
                    child: Text(
                      widget.isExpense ? "Expense" : "Income",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const Spacer()
                ],
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // Amount section at the top
          AmountWidget(controller: amountEditingController),

          // Main content with form fields and button
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: ColorConstants.getCardColor(context),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Column(
                children: [
                  // Form fields in a scrollable area
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.only(
                        left: 20,
                        right: 20,
                        top: 30,
                        bottom: 10,
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Category field
                            Text(
                              "Category",
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                                color: ColorConstants.getTextColor(context)
                                    .withValues(alpha: 153), // 0.6 opacity
                              ),
                            ),
                            8.height(),
                            TextFormField(
                              controller: categoryController,
                              readOnly: true,
                              validator: (value) {
                                if (value == null || value.trim() == "") {
                                  return "Required";
                                }
                                return null;
                              },
                              onTap: () {
                                showModalBottomSheet(
                                  context: context,
                                  builder: (context) => Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 20,
                                    ),
                                    width: 800,
                                    child: Column(
                                      children: [
                                        Text(
                                          "Category",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18,
                                            color: ColorConstants.getTextColor(
                                                context),
                                          ),
                                        ),
                                        BlocBuilder<CategoryBloc,
                                            CategoryState>(
                                          builder: (context, state) {
                                            if (state is CategoryLoading) {
                                              return const Center(
                                                child:
                                                    CircularProgressIndicator(),
                                              );
                                            } else if (state
                                                is CategoryLoaded) {
                                              return Scrollbar(
                                                child: ListView.separated(
                                                  separatorBuilder:
                                                      (context, index) =>
                                                          10.height(),
                                                  itemBuilder:
                                                      (context, index) =>
                                                          CustomInkWell(
                                                    onTap: () {
                                                      setState(() {
                                                        categoryType = state
                                                            .categoryList[index]
                                                            .categoryType;
                                                        categoryEntity =
                                                            state.categoryList[
                                                                index];
                                                        categoryController
                                                                .text =
                                                            state
                                                                .categoryList[
                                                                    index]
                                                                .categoryName;
                                                      });
                                                      context.pop();
                                                    },
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Row(
                                                          children: [
                                                            CategoryIconWidget(
                                                                categoryType: state
                                                                    .categoryList[
                                                                        index]
                                                                    .categoryType),
                                                            10.width(),
                                                            Text(
                                                              state
                                                                  .categoryList[
                                                                      index]
                                                                  .categoryName,
                                                              style: TextStyle(
                                                                fontSize: 16,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w400,
                                                                color: ColorConstants
                                                                    .getTextColor(
                                                                        context),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        if (state
                                                                .categoryList[
                                                                    index]
                                                                .categoryType ==
                                                            categoryType)
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .only(
                                                                    right: 5),
                                                            child: SvgPicture.asset(
                                                                "assets/svg/common/success.svg"),
                                                          ),
                                                      ],
                                                    ),
                                                  ),
                                                  itemCount:
                                                      state.categoryList.length,
                                                ),
                                              );
                                            } else {
                                              return Center(
                                                child: Text(
                                                  "No category found",
                                                  style: TextStyle(
                                                    color: ColorConstants
                                                        .getTextColor(context),
                                                  ),
                                                ),
                                              );
                                            }
                                          },
                                        ).expand()
                                      ],
                                    ),
                                  ),
                                );
                              },
                              decoration: InputDecoration(
                                disabledBorder:
                                    StyleConstants.textFormFieldBorder(),
                                enabledBorder:
                                    StyleConstants.textFormFieldBorder(),
                                border: StyleConstants.textFormFieldBorder(),
                                hintText: "Select a category",
                                suffixIcon: const DropDownIcon(),
                              ),
                            ),

                            24.height(),

                            // Date field
                            Text(
                              "Date",
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                                color: ColorConstants.getTextColor(context)
                                    .withValues(alpha: 153), // 0.6 opacity
                              ),
                            ),
                            8.height(),
                            TextFormField(
                              validator: (value) {
                                if (value == null || value.trim() == "") {
                                  return "Required";
                                }
                                return null;
                              },
                              readOnly: true,
                              onTap: () {
                                _selectDate(context);
                                setState(() {
                                  dateController.text =
                                      DateFormat('dd-MMMM-yyyy').format(date);
                                });
                              },
                              controller: dateController,
                              decoration: InputDecoration(
                                disabledBorder:
                                    StyleConstants.textFormFieldBorder(),
                                enabledBorder:
                                    StyleConstants.textFormFieldBorder(),
                                border: StyleConstants.textFormFieldBorder(),
                                hintText: "Select date",
                                suffixIcon: Icon(Icons.calendar_today_outlined,
                                    size: 20,
                                    color: ColorConstants.getTextColor(context)
                                        .withValues(alpha: 153)),
                              ),
                            ),

                            24.height(),

                            // Description field
                            Text(
                              "Description",
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                                color: ColorConstants.getTextColor(context)
                                    .withValues(alpha: 153), // 0.6 opacity
                              ),
                            ),
                            8.height(),
                            TextFormField(
                              validator: (value) {
                                if (value == null || value.trim() == "") {
                                  return "Required";
                                }
                                return null;
                              },
                              controller: descriptionController,
                              decoration: InputDecoration(
                                disabledBorder:
                                    StyleConstants.textFormFieldBorder(),
                                enabledBorder:
                                    StyleConstants.textFormFieldBorder(),
                                border: StyleConstants.textFormFieldBorder(),
                                hintText: "Enter description",
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Continue/Save button at the bottom
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 16),
                    child: SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: () {
                          if (amountEditingController.text.isEmpty) {
                            "Please Enter the amount".showSnack();
                          }
                          if (_formKey.currentState!.validate() &&
                              amountEditingController.text.trim() != "" &&
                              categoryType != null &&
                              categoryEntity != null) {
                            if (widget.transactionEntity != null) {
                              context.read<TransactionBloc>().add(
                                    EditTransactionEvent(
                                      id: widget.transactionEntity!.id,
                                      amount: amountEditingController.text,
                                      description: descriptionController.text,
                                      isExpense: widget.isExpense,
                                      categoryType: categoryType!,
                                      categoryModel: categoryEntity!,
                                      date: date,
                                    ),
                                  );
                            } else {
                              context.read<TransactionBloc>().add(
                                    AddTransactionEvent(
                                      amount: amountEditingController.text,
                                      description: descriptionController.text,
                                      isExpense: widget.isExpense,
                                      categoryType: categoryType!,
                                      categoryModel: categoryEntity!,
                                      date: date,
                                    ),
                                  );
                            }
                            // Update total amounts
                            context
                                .read<TotalTransactionCubit>()
                                .getTotalAmount();

                            // Refresh budgets when transaction is added/edited
                            context
                                .read<BudgetBloc>()
                                .add(const RefreshBudgetsOnTransactionChange());

                            context.pop();
                          }
                        },
                        style: StyleConstants.elevatedButtonStyle(
                            context: context),
                        child: Text(
                          widget.transactionEntity == null
                              ? "Continue"
                              : "Save",
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: date,
        firstDate: DateTime(2015, 8),
        lastDate: DateTime.now());
    if (picked != null && picked != date) {
      setState(() {
        date = picked;
      });
    }
    log(date.hour.toString(), name: "date hour");
    log(date.minute.toString(), name: "date hour");
  }
}

class DropDownIcon extends StatelessWidget {
  const DropDownIcon({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      height: 20,
      width: 20,
      child: SvgPicture.asset(
        "assets/svg/common/arrow_down_rounded.svg",
        colorFilter: ColorFilter.mode(
          ColorConstants.getBorderColor(context),
          BlendMode.srcIn,
        ),
      ),
    );
  }
}

class AmountWidget extends StatelessWidget {
  const AmountWidget({
    super.key,
    required this.controller,
  });

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          30.height(),
          Text(
            "How much?",
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9), // 0.8 opacity
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          10.height(),
          TextFormField(
            controller: controller,
            decoration: InputDecoration(
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              filled: true,
              fillColor: Colors.white.withValues(alpha: 0.01), // 0.1 opacity
              hintText: "0",
              hintStyle: TextStyle(
                color: Colors.white.withValues(alpha: 179), // 0.7 opacity
                fontSize: 70,
                fontWeight: FontWeight.bold,
              ),
              prefix: Text(
                CurrencyFormatter.getCurrencySymbol(context),
                style: const TextStyle(
                  fontSize: 70,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              contentPadding: EdgeInsets.zero,
            ),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 70,
              fontWeight: FontWeight.bold,
            ),
            keyboardType: TextInputType.number,
            textAlign: TextAlign.left,
            autofocus: true,
          ),
          10.height(), // Add some space at the bottom
        ],
      ),
    );
  }
}
