import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:money_track/core/constants/colors.dart';
import 'package:money_track/core/widgets/enhanced_widgets.dart';
import 'package:money_track/core/utils/currency_formatter.dart';
import 'package:money_track/features/groups/domain/entities/group_entity.dart';
import 'package:money_track/features/groups/domain/entities/settlement_entity.dart';
import 'package:money_track/features/groups/domain/entities/balance_entity.dart';
import 'package:money_track/features/groups/domain/usecases/settlement/add_settlement_usecase.dart';
import 'package:money_track/features/groups/presentation/cubit/group_details_cubit.dart';
import 'package:money_track/app/di/injection_container.dart';
import 'package:money_track/core/extensions/result_extensions.dart';

class AddSettlementPage extends StatefulWidget {
  final GroupEntity group;
  final SimplifiedDebt? suggestedDebt;
  final SettlementEntity? settlementToEdit;

  const AddSettlementPage({
    super.key,
    required this.group,
    this.suggestedDebt,
    this.settlementToEdit,
  });

  @override
  State<AddSettlementPage> createState() => _AddSettlementPageState();
}

class _AddSettlementPageState extends State<AddSettlementPage> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _notesController = TextEditingController();

  String? _selectedPayerId;
  String? _selectedReceiverId;
  PaymentMethod _selectedPaymentMethod = PaymentMethod.cash;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeForm();
  }

  void _initializeForm() {
    if (widget.settlementToEdit != null) {
      // Editing existing settlement
      final settlement = widget.settlementToEdit!;
      _amountController.text = settlement.amount.toString();
      _descriptionController.text = settlement.description ?? '';
      _notesController.text = settlement.notes ?? '';
      _selectedPayerId = settlement.payerId;
      _selectedReceiverId = settlement.receiverId;
      _selectedPaymentMethod = settlement.paymentMethod;
    } else if (widget.suggestedDebt != null) {
      // Pre-fill from suggested debt
      final debt = widget.suggestedDebt!;
      _amountController.text = debt.amount.toString();
      _selectedPayerId = debt.debtorId;
      _selectedReceiverId = debt.creditorId;
      _descriptionController.text = 'Settlement payment';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.settlementToEdit != null
            ? 'Edit Settlement'
            : 'Record Settlement'),
        backgroundColor: ColorConstants.getThemeColor(context),
        foregroundColor: Colors.white,
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveSettlement,
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text(
                    'Save',
                    style: TextStyle(color: Colors.white),
                  ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildSuggestedDebtCard(),
            const SizedBox(height: 24),
            _buildParticipantsSection(),
            const SizedBox(height: 24),
            _buildAmountSection(),
            const SizedBox(height: 24),
            _buildPaymentMethodSection(),
            const SizedBox(height: 24),
            _buildDetailsSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestedDebtCard() {
    if (widget.suggestedDebt == null) return const SizedBox.shrink();

    final debt = widget.suggestedDebt!;
    return AppCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.lightbulb_outline,
                  color: ColorConstants.getThemeColor(context),
                ),
                const SizedBox(width: 8),
                Text(
                  'Suggested Settlement',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: ColorConstants.getThemeColor(context),
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              '${debt.debtorName} owes ${debt.creditorName}',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 4),
            Text(
              CurrencyFormatter.format(context, debt.amount),
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: ColorConstants.getThemeColor(context),
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildParticipantsSection() {
    return AppCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Participants',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedPayerId,
              decoration: const InputDecoration(
                labelText: 'Who paid?',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person_outline),
              ),
              items: widget.group.members
                  .map((member) => DropdownMenuItem(
                        value: member.id,
                        child: Text(member.name),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedPayerId = value;
                });
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please select who made the payment';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedReceiverId,
              decoration: const InputDecoration(
                labelText: 'Who received the payment?',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
              items: widget.group.members
                  .where((member) => member.id != _selectedPayerId)
                  .map((member) => DropdownMenuItem(
                        value: member.id,
                        child: Text(member.name),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedReceiverId = value;
                });
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please select who received the payment';
                }
                if (value == _selectedPayerId) {
                  return 'Payer and receiver cannot be the same person';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAmountSection() {
    return AppCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Amount',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _amountController,
              decoration: const InputDecoration(
                labelText: 'Settlement Amount',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.attach_money),
                suffixText: 'USD',
              ),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
              ],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter an amount';
                }
                final amount = double.tryParse(value);
                if (amount == null || amount <= 0) {
                  return 'Please enter a valid amount greater than 0';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethodSection() {
    return AppCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Payment Method',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<PaymentMethod>(
              value: _selectedPaymentMethod,
              decoration: const InputDecoration(
                labelText: 'How was the payment made?',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.payment),
              ),
              items: PaymentMethod.values
                  .map((method) => DropdownMenuItem(
                        value: method,
                        child: Row(
                          children: [
                            Icon(_getPaymentMethodIcon(method), size: 20),
                            const SizedBox(width: 8),
                            Text(_getPaymentMethodName(method)),
                          ],
                        ),
                      ))
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedPaymentMethod = value;
                  });
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailsSection() {
    return AppCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Additional Details',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description (optional)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.description),
                hintText: 'e.g., Dinner payment, Rent settlement',
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Notes (optional)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.note),
                hintText: 'Any additional notes about this settlement',
              ),
              maxLines: 3,
            ),
          ],
        ),
      ),
    );
  }

  IconData _getPaymentMethodIcon(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.cash:
        return Icons.money;
      case PaymentMethod.bankTransfer:
        return Icons.account_balance;
      case PaymentMethod.digitalWallet:
        return Icons.phone_android;
      case PaymentMethod.creditCard:
        return Icons.credit_card;
      case PaymentMethod.other:
        return Icons.more_horiz;
    }
  }

  String _getPaymentMethodName(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.cash:
        return 'Cash';
      case PaymentMethod.bankTransfer:
        return 'Bank Transfer';
      case PaymentMethod.digitalWallet:
        return 'Digital Wallet';
      case PaymentMethod.creditCard:
        return 'Credit Card';
      case PaymentMethod.other:
        return 'Other';
    }
  }

  Future<void> _saveSettlement() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final amount = double.parse(_amountController.text);
      final payerName =
          widget.group.members.firstWhere((m) => m.id == _selectedPayerId).name;
      final receiverName = widget.group.members
          .firstWhere((m) => m.id == _selectedReceiverId)
          .name;

      final settlement = SettlementEntity(
        id: widget.settlementToEdit?.id ??
            DateTime.now().millisecondsSinceEpoch.toString(),
        groupId: widget.group.id,
        payerId: _selectedPayerId!,
        payerName: payerName,
        receiverId: _selectedReceiverId!,
        receiverName: receiverName,
        amount: amount,
        currency:
            'USD', // Default currency (could be enhanced with group settings)
        paymentMethod: _selectedPaymentMethod,
        status: SettlementStatus.pending,
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
        createdAt: widget.settlementToEdit?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Use the AddSettlementUseCase to save the settlement
      final addSettlementUseCase = sl<AddSettlementUseCase>();
      final result = await addSettlementUseCase(
        params: AddSettlementParams(settlement: settlement),
      );

      if (result.isError) {
        throw Exception(result.error?.message ?? 'Failed to save settlement');
      }

      // Refresh the group details to show the new settlement
      if (mounted) {
        final cubit = context.read<GroupDetailsCubit>();
        await cubit.refreshGroupDetails(widget.group.id);
      }

      if (mounted) {
        Navigator.of(context).pop(settlement);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.settlementToEdit != null
                ? 'Settlement updated successfully'
                : 'Settlement recorded successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving settlement: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    _notesController.dispose();
    super.dispose();
  }
}
