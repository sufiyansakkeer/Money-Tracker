import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:money_track/core/constants/colors.dart';
import 'package:money_track/core/constants/style_constants.dart';
import 'package:money_track/core/utils/sized_box_extension.dart';
import 'package:money_track/domain/entities/category_entity.dart';
import 'package:money_track/features/budget/domain/entities/budget_entity.dart';
import 'package:money_track/features/budget/presentation/bloc/budget_bloc.dart';
import 'package:money_track/features/categories/presentation/bloc/category_bloc.dart';
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
      _selectedPeriodType = widget.budget!.periodType;
      _startDate = widget.budget!.startDate;
      _isActive = widget.budget!.isActive;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Budget' : 'Add Budget'),
        backgroundColor: ColorConstants.getThemeColor(context),
        foregroundColor: Colors.white,
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Budget name
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Budget Name',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(16)),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a name';
                    }
                    return null;
                  },
                ),
                16.height(),

                // Budget amount
                TextFormField(
                  controller: _amountController,
                  decoration: const InputDecoration(
                    labelText: 'Budget Amount',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(16)),
                    ),
                    prefixIcon: Icon(Icons.attach_money),
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                        RegExp(r'^\d+\.?\d{0,2}')),
                  ],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an amount';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Please enter a valid number';
                    }
                    if (double.parse(value) <= 0) {
                      return 'Amount must be greater than zero';
                    }
                    return null;
                  },
                ),
                16.height(),

                // Category selection
                const Text(
                  'Category',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                8.height(),
                BlocBuilder<CategoryBloc, CategoryState>(
                  builder: (context, state) {
                    if (state is CategoryLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (state is CategoryLoaded) {
                      // Filter to only show expense categories
                      final expenseCategories = state.categoryList
                          .where((c) => c.type == TransactionType.expense)
                          .toList();

                      if (_selectedCategory == null &&
                          expenseCategories.isNotEmpty) {
                        _selectedCategory = expenseCategories.first;
                      }

                      return DropdownButtonFormField<CategoryEntity>(
                        value: _selectedCategory,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(16)),
                          ),
                        ),
                        items: expenseCategories.map((category) {
                          return DropdownMenuItem<CategoryEntity>(
                            value: category,
                            child: Row(
                              children: [
                                Icon(_getCategoryIcon(category.categoryType)),
                                const SizedBox(width: 8),
                                Text(category.categoryName),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedCategory = value;
                          });
                        },
                        validator: (value) {
                          if (value == null) {
                            return 'Please select a category';
                          }
                          return null;
                        },
                      );
                    }

                    return const Text('Failed to load categories');
                  },
                ),
                16.height(),

                // Period type selection
                const Text(
                  'Budget Period',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                8.height(),
                Row(
                  children: [
                    Expanded(
                      child: RadioListTile<BudgetPeriodType>(
                        title: const Text('Weekly'),
                        value: BudgetPeriodType.weekly,
                        groupValue: _selectedPeriodType,
                        onChanged: (value) {
                          setState(() {
                            _selectedPeriodType = value!;
                          });
                        },
                        activeColor: ColorConstants.getThemeColor(context),
                      ),
                    ),
                    Expanded(
                      child: RadioListTile<BudgetPeriodType>(
                        title: const Text('Monthly'),
                        value: BudgetPeriodType.monthly,
                        groupValue: _selectedPeriodType,
                        onChanged: (value) {
                          setState(() {
                            _selectedPeriodType = value!;
                          });
                        },
                        activeColor: ColorConstants.getThemeColor(context),
                      ),
                    ),
                  ],
                ),
                16.height(),

                // Start date selection
                const Text(
                  'Start Date',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
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
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today),
                        const SizedBox(width: 8),
                        Text(
                          '${_startDate.day}/${_startDate.month}/${_startDate.year}',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ),
                16.height(),

                // Active status
                SwitchListTile(
                  title: const Text(
                    'Active Budget',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  value: _isActive,
                  onChanged: (value) {
                    setState(() {
                      _isActive = value;
                    });
                  },
                  activeColor: ColorConstants.getThemeColor(context),
                ),
                32.height(),

                // Save button
                ElevatedButton(
                  onPressed: _saveBudget,
                  style: StyleConstants.elevatedButtonStyle(context: context),
                  child: Text(
                    _isEditing ? 'Update Budget' : 'Save Budget',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _saveBudget() {
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

  IconData _getCategoryIcon(categoryType) {
    switch (categoryType) {
      case CategoryType.salary:
        return Icons.attach_money;
      case CategoryType.shopping:
        return Icons.shopping_bag;
      case CategoryType.food:
        return Icons.restaurant;
      case CategoryType.transportation:
        return Icons.directions_car;
      case CategoryType.subscription:
        return Icons.subscriptions;
      case CategoryType.other:
      default:
        return Icons.category;
    }
  }
}
