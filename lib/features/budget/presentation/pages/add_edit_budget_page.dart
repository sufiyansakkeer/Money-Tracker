import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:money_track/core/constants/colors.dart';
import 'package:money_track/core/constants/style_constants.dart';
import 'package:money_track/core/utils/currency_formatter.dart';
import 'package:money_track/core/utils/navigation_extension.dart';
import 'package:money_track/core/utils/sized_box_extension.dart';
import 'package:money_track/core/utils/widget_extension.dart';
import 'package:money_track/core/widgets/category_icon_widget.dart';
import 'package:money_track/core/widgets/custom_inkwell.dart';
import 'package:money_track/domain/entities/category_entity.dart';
import 'package:money_track/features/budget/domain/entities/budget_entity.dart';
import 'package:money_track/features/budget/presentation/bloc/budget_bloc.dart';
import 'package:money_track/features/categories/presentation/bloc/category_bloc.dart';
import 'package:money_track/features/transactions/presentation/pages/transaction_list/widgets/custom_choice_chip.dart';
import 'package:svg_flutter/svg.dart';
import 'package:uuid/uuid.dart';

class AddEditBudgetPage extends StatefulWidget {
  final BudgetEntity? budget;

  const AddEditBudgetPage({
    super.key,
    this.budget,
  });

  @override
  State<AddEditBudgetPage> createState() => _AddEditBudgetPageState();
}

class _AddEditBudgetPageState extends State<AddEditBudgetPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  final _categoryController = TextEditingController();

  CategoryEntity? _selectedCategory;
  BudgetPeriodType _selectedPeriodType = BudgetPeriodType.monthly;
  DateTime _startDate = DateTime.now();
  bool _isActive = true;

  bool get _isEditing => widget.budget != null;

  @override
  void initState() {
    super.initState();

    // Load categories
    context.read<CategoryBloc>().add(GetAllCategoriesEvent());

    // Initialize form if editing
    if (_isEditing) {
      _nameController.text = widget.budget!.name;
      _amountController.text = widget.budget!.amount.toString();
      _selectedCategory = widget.budget!.category;
      _categoryController.text = widget.budget!.category.categoryName;
      _selectedPeriodType = widget.budget!.periodType;
      _startDate = widget.budget!.startDate;
      _isActive = widget.budget!.isActive;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = ColorConstants.getThemeColor(context);

    return Scaffold(
      backgroundColor: themeColor,
      appBar: PreferredSize(
        preferredSize: const Size(double.infinity, 50),
        child: SafeArea(
          child: Container(
            color: themeColor,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    child: SvgPicture.asset(
                      "assets/svg/common/arrow_left_white.svg",
                      height: 20,
                    ),
                  ),
                  const Spacer(),
                  Center(
                    child: Text(
                      _isEditing ? 'Edit Budget' : 'Add Budget',
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
      body: BlocListener<BudgetBloc, BudgetState>(
        listener: (context, state) {
          if (state is BudgetAdded || state is BudgetUpdated) {
            Navigator.pop(context);
          } else if (state is BudgetError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        child: Column(
          children: [
            // Amount section at the top
            _buildAmountWidget(),

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
                              // Budget name
                              Text(
                                "Budget Name",
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                  color: ColorConstants.getTextColor(context)
                                      .withValues(alpha: 153), // 0.6 opacity
                                ),
                              ),
                              8.height(),
                              TextFormField(
                                controller: _nameController,
                                decoration: InputDecoration(
                                  disabledBorder:
                                      StyleConstants.textFormFieldBorder(),
                                  enabledBorder:
                                      StyleConstants.textFormFieldBorder(),
                                  border: StyleConstants.textFormFieldBorder(),
                                  hintText: "Enter budget name",
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter a name';
                                  }
                                  return null;
                                },
                              ),
                              16.height(),

                              // Category selection
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
                                controller: _categoryController,
                                readOnly: true,
                                decoration: InputDecoration(
                                  disabledBorder:
                                      StyleConstants.textFormFieldBorder(),
                                  enabledBorder:
                                      StyleConstants.textFormFieldBorder(),
                                  border: StyleConstants.textFormFieldBorder(),
                                  hintText: "Select a category",
                                  suffixIcon: const DropDownIcon(),
                                ),
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
                                              color:
                                                  ColorConstants.getTextColor(
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
                                                // Filter to only show expense categories
                                                final expenseCategories = state
                                                    .categoryList
                                                    .where((c) =>
                                                        c.type ==
                                                        TransactionType.expense)
                                                    .toList();

                                                if (_selectedCategory == null &&
                                                    expenseCategories
                                                        .isNotEmpty) {
                                                  _selectedCategory =
                                                      expenseCategories.first;
                                                }

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
                                                          _selectedCategory =
                                                              expenseCategories[
                                                                  index];
                                                          _categoryController
                                                                  .text =
                                                              expenseCategories[
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
                                                                  categoryType:
                                                                      expenseCategories[
                                                                              index]
                                                                          .categoryType),
                                                              10.width(),
                                                              Text(
                                                                expenseCategories[
                                                                        index]
                                                                    .categoryName,
                                                                style:
                                                                    TextStyle(
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
                                                          if (expenseCategories[
                                                                  index] ==
                                                              _selectedCategory)
                                                            Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .only(
                                                                      right: 5),
                                                              child: SvgPicture
                                                                  .asset(
                                                                      "assets/svg/common/success.svg"),
                                                            ),
                                                        ],
                                                      ),
                                                    ),
                                                    itemCount: expenseCategories
                                                        .length,
                                                  ),
                                                ).expand();
                                              } else {
                                                return Center(
                                                  child: Text(
                                                    "No category found",
                                                    style: TextStyle(
                                                      color: ColorConstants
                                                          .getTextColor(
                                                              context),
                                                    ),
                                                  ),
                                                );
                                              }
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                              16.height(),

                              // Period type selection
                              Text(
                                "Budget Period",
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                  color: ColorConstants.getTextColor(context)
                                      .withValues(alpha: 153), // 0.6 opacity
                                ),
                              ),
                              8.height(),
                              Row(
                                children: [
                                  CustomChoiceChip(
                                    name: "Weekly",
                                    selected: _selectedPeriodType ==
                                        BudgetPeriodType.weekly,
                                    onSelected: (value) {
                                      setState(() {
                                        _selectedPeriodType =
                                            BudgetPeriodType.weekly;
                                      });
                                    },
                                  ),
                                  10.width(),
                                  CustomChoiceChip(
                                    name: "Monthly",
                                    selected: _selectedPeriodType ==
                                        BudgetPeriodType.monthly,
                                    onSelected: (value) {
                                      setState(() {
                                        _selectedPeriodType =
                                            BudgetPeriodType.monthly;
                                      });
                                    },
                                  ),
                                ],
                              ),
                              16.height(),

                              // Start date selection
                              Text(
                                "Start Date",
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                  color: ColorConstants.getTextColor(context)
                                      .withValues(alpha: 153), // 0.6 opacity
                                ),
                              ),
                              8.height(),
                              InkWell(
                                onTap: () async {
                                  final pickedDate = await showDatePicker(
                                    context: context,
                                    initialDate: _startDate,
                                    firstDate: DateTime(2020),
                                    lastDate: DateTime(2030),
                                  );

                                  if (pickedDate != null) {
                                    setState(() {
                                      _startDate = pickedDate;
                                    });
                                  }
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 16),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                        color: ColorConstants.getBorderColor(
                                            context)),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.calendar_today,
                                        color: ColorConstants.getTextColor(
                                            context),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        '${_startDate.day}/${_startDate.month}/${_startDate.year}',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: ColorConstants.getTextColor(
                                              context),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              16.height(),

                              // Active status
                              SwitchListTile(
                                title: Text(
                                  'Active Budget',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                    color: ColorConstants.getTextColor(context)
                                        .withValues(alpha: 153), // 0.6 opacity
                                  ),
                                ),
                                value: _isActive,
                                onChanged: (value) {
                                  setState(() {
                                    _isActive = value;
                                  });
                                },
                                activeColor: themeColor,
                                // activeThumbColor: themeColor,
                                contentPadding: EdgeInsets.zero,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Save button at the bottom
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 16),
                      child: SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton(
                          onPressed: _saveBudget,
                          style: StyleConstants.elevatedButtonStyle(
                              context: context),
                          child: Text(
                            _isEditing ? 'Update Budget' : 'Continue',
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
      ),
    );
  }

  Widget _buildAmountWidget() {
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
            controller: _amountController,
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
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
            ],
          ),
          10.height(),
        ],
      ),
    );
  }

  void _saveBudget() {
    // Check if amount is entered
    if (_amountController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter an amount")),
      );
      return;
    }

    // Check if amount is valid
    if (double.tryParse(_amountController.text) == null ||
        double.parse(_amountController.text) <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a valid amount")),
      );
      return;
    }

    if (_formKey.currentState!.validate() && _selectedCategory != null) {
      final budget = BudgetEntity(
        id: _isEditing ? widget.budget!.id : const Uuid().v4(),
        name: _nameController.text,
        amount: double.parse(_amountController.text),
        category: _selectedCategory!,
        periodType: _selectedPeriodType,
        startDate: _startDate,
        isActive: _isActive,
      );

      if (_isEditing) {
        context.read<BudgetBloc>().add(UpdateBudget(budget));
      } else {
        context.read<BudgetBloc>().add(AddBudget(budget));
      }
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
          ColorConstants.getBorderColor(context),
          BlendMode.srcIn,
        ),
      ),
    );
  }
}
