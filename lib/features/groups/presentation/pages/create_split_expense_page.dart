import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:money_track/core/constants/colors.dart';
import 'package:money_track/core/constants/style_constants.dart';
import 'package:money_track/core/utils/sized_box_extension.dart';
import 'package:money_track/core/utils/snack_bar_extension.dart';
import 'package:money_track/domain/entities/category_entity.dart';
import 'package:money_track/features/categories/presentation/bloc/category_bloc.dart';
import 'package:money_track/features/groups/domain/entities/group_entity.dart';
import 'package:money_track/features/groups/domain/entities/split_details.dart';
import 'package:money_track/features/groups/domain/utils/split_calculator.dart';
import 'package:money_track/features/transactions/presentation/bloc/transaction_bloc.dart';

class CreateSplitExpensePage extends StatefulWidget {
  final GroupEntity group;

  const CreateSplitExpensePage({super.key, required this.group});

  @override
  State<CreateSplitExpensePage> createState() => _CreateSplitExpensePageState();
}

class _CreateSplitExpensePageState extends State<CreateSplitExpensePage> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();

  CategoryEntity? _selectedCategory;
  GroupMember? _selectedPayer;
  SplitType _splitType = SplitType.equal;
  final Map<String, double> _customAmounts = {};
  final Map<String, double> _percentages = {};
  final Set<String> _selectedMembers = {};

  @override
  void initState() {
    super.initState();
    context.read<CategoryBloc>().add(GetAllCategoriesEvent());
    // Select all members by default
    _selectedMembers.addAll(widget.group.members.map((m) => m.id));
    // Initialize custom amounts and percentages
    for (final member in widget.group.members) {
      _customAmounts[member.id] = 0.0;
      _percentages[member.id] = 100.0 / widget.group.members.length;
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _createSplitExpense() {
    if (_formKey.currentState!.validate()) {
      if (_selectedCategory == null) {
        'Please select a category'.showSnack();
        return;
      }
      if (_selectedPayer == null) {
        'Please select who paid'.showSnack();
        return;
      }
      if (_selectedMembers.isEmpty) {
        'Please select at least one member to split with'.showSnack();
        return;
      }

      final amount = double.tryParse(_amountController.text) ?? 0.0;

      // Validate amount
      if (amount <= 0) {
        'Please enter a valid amount greater than zero'.showSnack();
        return;
      }

      final transactionId = DateTime.now().millisecondsSinceEpoch.toString();

      try {
        // Additional validation for custom and percentage splits
        if (_splitType == SplitType.custom) {
          final totalCustomAmount =
              _customAmounts.values.fold(0.0, (sum, amount) => sum + amount);
          if ((totalCustomAmount - amount).abs() > 0.01) {
            'Custom split amounts must equal the total amount'.showSnack();
            return;
          }
        } else if (_splitType == SplitType.percentage) {
          final totalPercentage = _percentages.values
              .fold(0.0, (sum, percentage) => sum + percentage);
          if ((totalPercentage - 100.0).abs() > 0.01) {
            'Percentages must add up to 100%'.showSnack();
            return;
          }
        }

        // Create split details
        final splitDetails = SplitCalculator.createSplitDetails(
          transactionId: transactionId,
          payerMemberId: _selectedPayer!.id,
          splitType: _splitType,
          totalAmount: amount,
          memberIds: _selectedMembers.toList(),
          customAmounts: _splitType == SplitType.custom ? _customAmounts : null,
          percentages: _splitType == SplitType.percentage ? _percentages : null,
        );

        // Add transaction and split details
        context.read<TransactionBloc>().add(AddTransactionEvent(
              amount: amount.toString(),
              date: DateTime.now(),
              categoryType: _selectedCategory!.categoryType,
              isExpense: true,
              categoryModel: _selectedCategory!,
              description: _notesController.text.trim().isEmpty
                  ? null
                  : _notesController.text.trim(),
              groupId: widget.group.id,
              splitDetails: splitDetails,
            ));
      } catch (e) {
        e.toString().showSnack();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Split Expense - ${widget.group.name}'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: BlocListener<TransactionBloc, TransactionState>(
        listener: (context, state) {
          if (state is TransactionAdded) {
            'Split expense created successfully'
                .showSnack(backgroundColor: Colors.green);
            Navigator.of(context).pop();
          } else if (state is TransactionError) {
            state.message.showSnack();
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Amount
                  _buildSectionTitle('Amount'),
                  TextFormField(
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    decoration: _buildInputDecoration(
                        'Enter amount', Icons.attach_money),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter an amount';
                      }
                      if (double.tryParse(value) == null ||
                          double.parse(value) <= 0) {
                        return 'Please enter a valid amount';
                      }
                      return null;
                    },
                  ),
                  16.height(),

                  // Category
                  _buildSectionTitle('Category'),
                  BlocBuilder<CategoryBloc, CategoryState>(
                    builder: (context, state) {
                      if (state is CategoryLoaded) {
                        final expenseCategories = state.categoryList
                            .where((c) => c.type == TransactionType.expense)
                            .toList();

                        return DropdownButtonFormField<CategoryEntity>(
                          value: _selectedCategory,
                          decoration: _buildInputDecoration(
                              'Select category', Icons.category),
                          items: expenseCategories.map((category) {
                            return DropdownMenuItem(
                              value: category,
                              child: Text(category.categoryName),
                            );
                          }).toList(),
                          onChanged: (category) {
                            setState(() {
                              _selectedCategory = category;
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
                      return const CircularProgressIndicator();
                    },
                  ),
                  16.height(),

                  // Who Paid
                  _buildSectionTitle('Who Paid?'),
                  DropdownButtonFormField<GroupMember>(
                    value: _selectedPayer,
                    decoration:
                        _buildInputDecoration('Select payer', Icons.person),
                    items: widget.group.members.map((member) {
                      return DropdownMenuItem(
                        value: member,
                        child: Text(member.name),
                      );
                    }).toList(),
                    onChanged: (member) {
                      setState(() {
                        _selectedPayer = member;
                      });
                    },
                    validator: (value) {
                      if (value == null) {
                        return 'Please select who paid';
                      }
                      return null;
                    },
                  ),
                  16.height(),

                  // Split Type
                  _buildSectionTitle('Split Type'),
                  _buildSplitTypeSelector(),
                  16.height(),

                  // Members Selection
                  _buildSectionTitle('Split With'),
                  _buildMemberSelection(),
                  16.height(),

                  // Split Details based on type
                  if (_splitType != SplitType.equal) ...[
                    _buildSplitDetails(),
                    16.height(),
                  ],

                  // Notes
                  _buildSectionTitle('Notes (Optional)'),
                  TextFormField(
                    controller: _notesController,
                    maxLines: 3,
                    decoration: _buildInputDecoration('Add notes', Icons.note),
                  ),
                  32.height(),

                  // Create Button
                  BlocBuilder<TransactionBloc, TransactionState>(
                    builder: (context, state) {
                      return SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: state is TransactionLoading
                              ? null
                              : _createSplitExpense,
                          style: StyleConstants.elevatedButtonStyle(
                              context: context),
                          child: state is TransactionLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white),
                                  ),
                                )
                              : const Text(
                                  'Create Split Expense',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 14,
          color: ColorConstants.getTextColor(context).withValues(alpha: 0.6),
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon),
      border: StyleConstants.textFormFieldBorder(),
      enabledBorder: StyleConstants.textFormFieldBorder(),
      focusedBorder: StyleConstants.textFormFieldBorder().copyWith(
        borderSide: BorderSide(
          color: ColorConstants.getThemeColor(context),
          width: 2,
        ),
      ),
    );
  }

  Widget _buildSplitTypeSelector() {
    return Row(
      children: [
        Expanded(
          child: RadioListTile<SplitType>(
            title: const Text('Equal'),
            value: SplitType.equal,
            groupValue: _splitType,
            onChanged: (value) {
              setState(() {
                _splitType = value!;
              });
            },
          ),
        ),
        Expanded(
          child: RadioListTile<SplitType>(
            title: const Text('Custom'),
            value: SplitType.custom,
            groupValue: _splitType,
            onChanged: (value) {
              setState(() {
                _splitType = value!;
              });
            },
          ),
        ),
        Expanded(
          child: RadioListTile<SplitType>(
            title: const Text('Percent'),
            value: SplitType.percentage,
            groupValue: _splitType,
            onChanged: (value) {
              setState(() {
                _splitType = value!;
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMemberSelection() {
    return Column(
      children: widget.group.members.map((member) {
        return CheckboxListTile(
          title: Text(member.name),
          subtitle: member.email != null ? Text(member.email!) : null,
          value: _selectedMembers.contains(member.id),
          onChanged: (selected) {
            setState(() {
              if (selected == true) {
                _selectedMembers.add(member.id);
              } else {
                _selectedMembers.remove(member.id);
              }
            });
          },
        );
      }).toList(),
    );
  }

  Widget _buildSplitDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _splitType == SplitType.custom ? 'Custom Amounts' : 'Percentages',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        8.height(),
        ...widget.group.members
            .where((m) => _selectedMembers.contains(m.id))
            .map((member) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Expanded(flex: 2, child: Text(member.name)),
                Expanded(
                  child: TextFormField(
                    initialValue: _splitType == SplitType.custom
                        ? _customAmounts[member.id]?.toString() ?? '0'
                        : _percentages[member.id]?.toString() ?? '0',
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      suffix:
                          Text(_splitType == SplitType.percentage ? '%' : ''),
                      border: const OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      final amount = double.tryParse(value) ?? 0.0;
                      if (_splitType == SplitType.custom) {
                        _customAmounts[member.id] = amount;
                      } else {
                        _percentages[member.id] = amount;
                      }
                    },
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}
