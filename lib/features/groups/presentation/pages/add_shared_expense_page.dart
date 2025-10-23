import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:money_track/features/groups/domain/entities/shared_expense_entity.dart';
import 'package:money_track/features/groups/domain/entities/group_entity.dart';
import 'package:money_track/data/models/category_model.dart';
import 'package:money_track/features/groups/presentation/widgets/split_type_selector.dart';
import 'package:money_track/features/groups/presentation/widgets/participant_selector.dart';
import 'package:money_track/features/groups/presentation/widgets/receipt_attachment_widget.dart';
import 'package:money_track/core/utils/expense_currency_formatter.dart';

class AddSharedExpensePage extends StatefulWidget {
  final GroupEntity group;
  final SharedExpenseEntity? expenseToEdit;

  const AddSharedExpensePage({
    Key? key,
    required this.group,
    this.expenseToEdit,
  }) : super(key: key);

  @override
  State<AddSharedExpensePage> createState() => _AddSharedExpensePageState();
}

class _AddSharedExpensePageState extends State<AddSharedExpensePage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();

  EnhancedSplitType _selectedSplitType = EnhancedSplitType.equal;
  CategoryModel? _selectedCategory;
  List<ExpenseParticipant> _participants = [];
  List<String> _receiptUrls = [];
  List<String> _tags = [];
  String _currency = 'USD';
  bool _isRecurring = false;
  String? _recurringPattern;
  DateTime? _recurringEndDate;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeForm();
  }

  void _initializeForm() {
    if (widget.expenseToEdit != null) {
      final expense = widget.expenseToEdit!;
      _titleController.text = expense.title;
      _descriptionController.text = expense.description ?? '';
      _amountController.text = expense.totalAmount.toString();
      _selectedSplitType = expense.splitType;
      _selectedCategory = CategoryModel.fromEntity(expense.category);
      _participants = List.from(expense.participants);
      _receiptUrls = List.from(expense.receiptUrls ?? []);
      _tags = List.from(expense.tags);
      _currency = expense.currency;
      _isRecurring = expense.isRecurring;
      _recurringPattern = expense.recurringPattern;
      _recurringEndDate = expense.recurringEndDate;
    } else {
      // Initialize with all group members as participants
      _participants = widget.group.members
          .map((member) => ExpenseParticipant(
                memberId: member.id,
                memberName: member.name,
                amount: 0.0,
                paidAmount: 0.0,
                isPayer: false,
              ))
          .toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.expenseToEdit != null
            ? 'Edit Expense'
            : 'Add Shared Expense'),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveExpense,
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Save'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildBasicInfoSection(),
            const SizedBox(height: 24),
            _buildSplitSection(),
            const SizedBox(height: 24),
            _buildParticipantsSection(),
            const SizedBox(height: 24),
            _buildReceiptSection(),
            const SizedBox(height: 24),
            _buildAdditionalOptionsSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildBasicInfoSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Expense Details',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                hintText: 'e.g., Dinner at restaurant',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a title';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description (optional)',
                hintText: 'Add more details...',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    controller: _amountController,
                    decoration: InputDecoration(
                      labelText: 'Amount',
                      prefixText:
                          ExpenseCurrencyFormatter.getCurrencySymbol(_currency),
                      border: const OutlineInputBorder(),
                    ),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                          RegExp(r'^\d*\.?\d{0,2}')),
                    ],
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter an amount';
                      }
                      final amount = double.tryParse(value);
                      if (amount == null || amount <= 0) {
                        return 'Please enter a valid amount';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      _updateParticipantAmounts();
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _currency,
                    decoration: const InputDecoration(
                      labelText: 'Currency',
                      border: OutlineInputBorder(),
                    ),
                    items: ['USD', 'EUR', 'GBP', 'JPY', 'CAD', 'AUD']
                        .map((currency) => DropdownMenuItem(
                              value: currency,
                              child: Text(currency),
                            ))
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _currency = value;
                        });
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Category selector would go here
            // _buildCategorySelector(),
          ],
        ),
      ),
    );
  }

  Widget _buildSplitSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Split Method',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            SplitTypeSelector(
              selectedType: _selectedSplitType,
              onTypeChanged: (type) {
                setState(() {
                  _selectedSplitType = type;
                  _updateParticipantAmounts();
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildParticipantsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Participants',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            ParticipantSelector(
              participants: _participants,
              splitType: _selectedSplitType,
              totalAmount: double.tryParse(_amountController.text) ?? 0.0,
              currency: _currency,
              onParticipantsChanged: (participants) {
                setState(() {
                  _participants = participants;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReceiptSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Receipts',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            ReceiptAttachmentWidget(
              receiptUrls: _receiptUrls,
              onReceiptsChanged: (urls) {
                setState(() {
                  _receiptUrls = urls;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdditionalOptionsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Additional Options',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Recurring Expense'),
              subtitle: const Text('Set up automatic recurring'),
              value: _isRecurring,
              onChanged: (value) {
                setState(() {
                  _isRecurring = value;
                });
              },
            ),
            if (_isRecurring) ...[
              const SizedBox(height: 16),
              // Recurring options would go here
              Text(
                'Recurring options coming soon...',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _updateParticipantAmounts() {
    final totalAmount = double.tryParse(_amountController.text) ?? 0.0;
    if (totalAmount <= 0 || _participants.isEmpty) return;

    // This would use the SplitCalculator to update participant amounts
    // For now, just equal split
    if (_selectedSplitType == EnhancedSplitType.equal) {
      final amountPerPerson = totalAmount / _participants.length;
      for (int i = 0; i < _participants.length; i++) {
        _participants[i] = _participants[i].copyWith(amount: amountPerPerson);
      }
    }
  }

  Future<void> _saveExpense() async {
    if (!_formKey.currentState!.validate()) return;
    if (_participants.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one participant')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Create or update expense
      // This would use the appropriate use case

      Navigator.of(context).pop(true); // Return success
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving expense: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _amountController.dispose();
    super.dispose();
  }
}
