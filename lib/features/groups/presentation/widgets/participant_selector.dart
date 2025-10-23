import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:money_track/features/groups/domain/entities/shared_expense_entity.dart';
import 'package:money_track/core/utils/expense_currency_formatter.dart';

class ParticipantSelector extends StatefulWidget {
  final List<ExpenseParticipant> participants;
  final EnhancedSplitType splitType;
  final double totalAmount;
  final String currency;
  final ValueChanged<List<ExpenseParticipant>> onParticipantsChanged;

  const ParticipantSelector({
    Key? key,
    required this.participants,
    required this.splitType,
    required this.totalAmount,
    required this.currency,
    required this.onParticipantsChanged,
  }) : super(key: key);

  @override
  State<ParticipantSelector> createState() => _ParticipantSelectorState();
}

class _ParticipantSelectorState extends State<ParticipantSelector> {
  late List<ExpenseParticipant> _participants;
  final Map<String, TextEditingController> _amountControllers = {};
  final Map<String, TextEditingController> _percentageControllers = {};
  final Map<String, TextEditingController> _shareControllers = {};

  @override
  void initState() {
    super.initState();
    _participants = List.from(widget.participants);
    _initializeControllers();
  }

  @override
  void didUpdateWidget(ParticipantSelector oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.splitType != widget.splitType ||
        oldWidget.totalAmount != widget.totalAmount) {
      _updateParticipantAmounts();
    }
  }

  void _initializeControllers() {
    for (final participant in _participants) {
      _amountControllers[participant.memberId] = TextEditingController(
        text: participant.amount.toStringAsFixed(2),
      );
      _percentageControllers[participant.memberId] = TextEditingController(
        text: (participant.percentage ?? 0).toStringAsFixed(1),
      );
      _shareControllers[participant.memberId] = TextEditingController(
        text: (participant.shares ?? 1).toStringAsFixed(0),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildParticipantList(),
        const SizedBox(height: 16),
        _buildSummary(),
      ],
    );
  }

  Widget _buildParticipantList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _participants.length,
      itemBuilder: (context, index) {
        final participant = _participants[index];
        return _buildParticipantTile(participant, index);
      },
    );
  }

  Widget _buildParticipantTile(ExpenseParticipant participant, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  child: Text(
                    participant.memberName.substring(0, 1).toUpperCase(),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        participant.memberName,
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      Text(
                        _getParticipantSubtitle(participant),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: participant.isPayer,
                  onChanged: (value) {
                    _updateParticipant(
                        index, participant.copyWith(isPayer: value));
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildAmountInput(participant, index),
          ],
        ),
      ),
    );
  }

  Widget _buildAmountInput(ExpenseParticipant participant, int index) {
    switch (widget.splitType) {
      case EnhancedSplitType.equal:
        return _buildReadOnlyAmount(participant);
      case EnhancedSplitType.exact:
        return _buildExactAmountInput(participant, index);
      case EnhancedSplitType.percentage:
        return _buildPercentageInput(participant, index);
      case EnhancedSplitType.shares:
        return _buildSharesInput(participant, index);
      case EnhancedSplitType.adjustment:
        return _buildAdjustmentInput(participant, index);
    }
  }

  Widget _buildReadOnlyAmount(ExpenseParticipant participant) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Amount:'),
          Text(
            ExpenseCurrencyFormatter.format(
                participant.amount, widget.currency),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildExactAmountInput(ExpenseParticipant participant, int index) {
    return TextFormField(
      controller: _amountControllers[participant.memberId],
      decoration: InputDecoration(
        labelText: 'Amount',
        prefixText: ExpenseCurrencyFormatter.getCurrencySymbol(widget.currency),
        border: const OutlineInputBorder(),
      ),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
      ],
      onChanged: (value) {
        final amount = double.tryParse(value) ?? 0.0;
        _updateParticipant(index, participant.copyWith(amount: amount));
      },
    );
  }

  Widget _buildPercentageInput(ExpenseParticipant participant, int index) {
    return Row(
      children: [
        Expanded(
          child: TextFormField(
            controller: _percentageControllers[participant.memberId],
            decoration: const InputDecoration(
              labelText: 'Percentage',
              suffixText: '%',
              border: OutlineInputBorder(),
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,1}')),
            ],
            onChanged: (value) {
              final percentage = double.tryParse(value) ?? 0.0;
              final amount = (widget.totalAmount * percentage) / 100;
              _updateParticipant(
                index,
                participant.copyWith(
                  percentage: percentage,
                  amount: amount,
                ),
              );
            },
          ),
        ),
        const SizedBox(width: 16),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            ExpenseCurrencyFormatter.format(
                participant.amount, widget.currency),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget _buildSharesInput(ExpenseParticipant participant, int index) {
    return Row(
      children: [
        Expanded(
          child: TextFormField(
            controller: _shareControllers[participant.memberId],
            decoration: const InputDecoration(
              labelText: 'Shares',
              hintText: '1',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
            ],
            onChanged: (value) {
              final shares = double.tryParse(value) ?? 1.0;
              _updateParticipant(
                index,
                participant.copyWith(shares: shares),
              );
              _recalculateShareAmounts();
            },
          ),
        ),
        const SizedBox(width: 16),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            ExpenseCurrencyFormatter.format(
                participant.amount, widget.currency),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget _buildAdjustmentInput(ExpenseParticipant participant, int index) {
    return _buildExactAmountInput(participant, index);
  }

  Widget _buildSummary() {
    final totalAssigned = _participants.fold(0.0, (sum, p) => sum + p.amount);
    final remaining = widget.totalAmount - totalAssigned;
    final isBalanced = remaining.abs() < 0.01;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isBalanced ? Colors.green[50] : Colors.orange[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isBalanced ? Colors.green : Colors.orange,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total Amount:'),
              Text(
                ExpenseCurrencyFormatter.format(
                    widget.totalAmount, widget.currency),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Assigned:'),
              Text(
                ExpenseCurrencyFormatter.format(totalAssigned, widget.currency),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                remaining >= 0 ? 'Remaining:' : 'Over by:',
                style: TextStyle(
                  color: isBalanced ? Colors.green : Colors.orange,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                ExpenseCurrencyFormatter.format(
                    remaining.abs(), widget.currency),
                style: TextStyle(
                  color: isBalanced ? Colors.green : Colors.orange,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getParticipantSubtitle(ExpenseParticipant participant) {
    if (participant.isPayer) {
      return 'Payer • Owes ${ExpenseCurrencyFormatter.format(participant.amount, widget.currency)}';
    }
    return 'Owes ${ExpenseCurrencyFormatter.format(participant.amount, widget.currency)}';
  }

  void _updateParticipant(int index, ExpenseParticipant updatedParticipant) {
    setState(() {
      _participants[index] = updatedParticipant;
    });
    widget.onParticipantsChanged(_participants);
  }

  void _updateParticipantAmounts() {
    if (widget.splitType == EnhancedSplitType.equal && widget.totalAmount > 0) {
      final amountPerPerson = widget.totalAmount / _participants.length;
      for (int i = 0; i < _participants.length; i++) {
        _participants[i] = _participants[i].copyWith(amount: amountPerPerson);
      }
      widget.onParticipantsChanged(_participants);
    }
  }

  void _recalculateShareAmounts() {
    final totalShares =
        _participants.fold(0.0, (sum, p) => sum + (p.shares ?? 1));
    if (totalShares > 0 && widget.totalAmount > 0) {
      for (int i = 0; i < _participants.length; i++) {
        final shares = _participants[i].shares ?? 1;
        final amount = (widget.totalAmount * shares) / totalShares;
        _participants[i] = _participants[i].copyWith(amount: amount);
      }
      widget.onParticipantsChanged(_participants);
    }
  }

  @override
  void dispose() {
    for (final controller in _amountControllers.values) {
      controller.dispose();
    }
    for (final controller in _percentageControllers.values) {
      controller.dispose();
    }
    for (final controller in _shareControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }
}
