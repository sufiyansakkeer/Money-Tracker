import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:money_track/core/constants/colors.dart';
import 'package:money_track/core/constants/style_constants.dart';
import 'package:money_track/helper/navigation_extension.dart';
import 'package:money_track/helper/sized_box_extension.dart';
import 'package:money_track/helper/snack_bar_extension.dart';
import 'package:money_track/helper/widget_extension.dart';
import 'package:money_track/models/categories_model/category_model.dart';
import 'package:money_track/models/transaction_model/transaction_model.dart';
import 'package:money_track/presentation/bloc/category/category_bloc.dart';
import 'package:money_track/presentation/bloc/transaction/total_transaction/total_transaction_cubit.dart';
import 'package:money_track/presentation/bloc/transaction/transaction_bloc.dart';
import 'package:money_track/presentation/pages/settings/widget/custom_app_bar.dart';
import 'package:money_track/presentation/widgets/category_icon_widget.dart';
import 'package:money_track/presentation/widgets/custom_inkwell.dart';
import 'package:svg_flutter/svg.dart';

class TransactionPage extends StatefulWidget {
  const TransactionPage(
      {super.key, required this.isExpense, this.transactionModel});
  final bool isExpense;
  final TransactionModel? transactionModel;
  @override
  State<TransactionPage> createState() => _TransactionPageState();
}

class _TransactionPageState extends State<TransactionPage> {
  late TextEditingController amountEditingController;
  late TextEditingController categoryController;
  late TextEditingController descriptionController;
  late TextEditingController dateController;
  CategoryType? categoryType;
  CategoryModel? categoryModel;
  DateTime date = DateTime.now();
  final _formKey = GlobalKey<FormState>();
  @override
  void initState() {
    amountEditingController = TextEditingController();
    categoryController = TextEditingController();
    descriptionController = TextEditingController();
    dateController = TextEditingController();
    if (widget.transactionModel != null) {
      categoryModel = widget.transactionModel!.categoryModel;
      categoryType = widget.transactionModel!.categoryType;
      date = widget.transactionModel!.date;
      amountEditingController.text = widget.transactionModel!.amount.toString();
      categoryController.text =
          widget.transactionModel!.categoryModel.categoryName;
      descriptionController.text = widget.transactionModel!.notes ?? "";
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
      appBar: customAppBar(
        context,
        title: widget.isExpense ? "Expense" : "Income",
        color: widget.isExpense
            ? ColorConstants.expenseColor
            : ColorConstants.incomeColor,
      ),
      body: Column(
        children: [
          AmountWidget(controller: amountEditingController),
          Container(
            // height: constraints.maxHeight,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(
                  20,
                ),
                topRight: Radius.circular(
                  20,
                ),
              ),
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 30,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // 10.height(),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
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
                                  const Text(
                                    "Category",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                  BlocBuilder<CategoryBloc, CategoryState>(
                                    builder: (context, state) {
                                      if (state is CategoryLoading) {
                                        return const Center(
                                          child: CircularProgressIndicator(),
                                        );
                                      } else if (state is CategoryLoaded) {
                                        return Scrollbar(
                                          child: ListView.separated(
                                            separatorBuilder:
                                                (context, index) => 10.height(),
                                            itemBuilder: (context, index) =>
                                                CustomInkWell(
                                              onTap: () {
                                                setState(() {
                                                  categoryType = state
                                                      .categoryList[index]
                                                      .categoryType;
                                                  categoryModel =
                                                      state.categoryList[index];
                                                  categoryController.text =
                                                      state.categoryList[index]
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
                                                            .categoryList[index]
                                                            .categoryName,
                                                        style: const TextStyle(
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.w400,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  if (state.categoryList[index]
                                                          .categoryType ==
                                                      categoryType)
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
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
                                        return const Center(
                                          child: Text("No category found"),
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
                          disabledBorder: StyleConstants.textFormFieldBorder(),
                          enabledBorder: StyleConstants.textFormFieldBorder(),
                          border: StyleConstants.textFormFieldBorder(),
                          hintText: "Category",
                          suffixIcon: const DropDownIcon(),
                        ),
                      ),
                      20.height(),
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
                          disabledBorder: StyleConstants.textFormFieldBorder(),
                          enabledBorder: StyleConstants.textFormFieldBorder(),
                          border: StyleConstants.textFormFieldBorder(),
                          hintText: "Date",
                        ),
                      ),
                      20.height(),
                      TextFormField(
                        validator: (value) {
                          if (value == null || value.trim() == "") {
                            return "Required";
                          }
                          return null;
                        },
                        controller: descriptionController,
                        decoration: InputDecoration(
                          disabledBorder: StyleConstants.textFormFieldBorder(),
                          enabledBorder: StyleConstants.textFormFieldBorder(),
                          border: StyleConstants.textFormFieldBorder(),
                          hintText: "Description",
                        ),
                      ),
                      20.height(),
                    ],
                  ),
                ),
                const Spacer(),
                ElevatedButton(
                  onPressed: () {
                    if (amountEditingController.text.isEmpty) {
                      "Please Enter the amount".showSnack();
                    }
                    if (_formKey.currentState!.validate() &&
                        amountEditingController.text.trim() != "" &&
                        categoryType != null &&
                        categoryModel != null) {
                      if (widget.transactionModel != null) {
                        context.read<TransactionBloc>().add(
                              EditTransactionEvent(
                                id: widget.transactionModel!.id!,
                                amount: amountEditingController.text,
                                description: descriptionController.text,
                                isExpense: widget.isExpense,
                                categoryType: categoryType!,
                                categoryModel: categoryModel!,
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
                                categoryModel: categoryModel!,
                                date: date,
                              ),
                            );
                      }
                      context.read<TotalTransactionCubit>().getTotalAmount();
                      context.pop();
                    }
                  },
                  style: StyleConstants.elevatedButtonStyle(),
                  child: Text(
                    widget.transactionModel == null ? "Continue" : "Save",
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ).expand(),
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
          ColorConstants.borderColor,
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          30.height(),
          const Text(
            "How much?",
            style: TextStyle(
              color: Color(0xFFDAD9D9),
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          TextFormField(
            controller: controller,
            decoration: const InputDecoration(
              border: InputBorder.none,
              hintText: "0",
              hintStyle: TextStyle(
                color: Color(0xFFE3E2E2),
                fontSize: 70,
                fontWeight: FontWeight.bold,
              ),
              prefix: Text(
                "₹",
                style: TextStyle(
                  fontSize: 70,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 70,
              fontWeight: FontWeight.bold,
            ),
            keyboardType: TextInputType.number,
            inputFormatters: const [],
          ),
        ],
      ),
    );
  }
}
