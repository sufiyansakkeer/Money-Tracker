import 'package:flutter/material.dart';
import 'package:money_track/features/groups/domain/entities/group_entity.dart';
import 'package:money_track/features/groups/domain/entities/split_details.dart';

class ExpenseSplitScreen extends StatefulWidget {
  final GroupEntity group;
  final double totalAmount;

  const ExpenseSplitScreen(
      {super.key, required this.group, required this.totalAmount});

  @override
  State<ExpenseSplitScreen> createState() => _ExpenseSplitScreenState();
}

class _ExpenseSplitScreenState extends State<ExpenseSplitScreen> {
  SplitType _splitType = SplitType.equal;
  String? _payerMemberId;
  final Map<String, TextEditingController> _controllers = {};

  @override
  void initState() {
    super.initState();
    _payerMemberId = widget.group.members.first.id;
    for (var member in widget.group.members) {
      _controllers[member.id] = TextEditingController();
    }
    _calculateSplits();
  }

  @override
  void dispose() {
    _controllers.forEach((_, controller) => controller.dispose());
    super.dispose();
  }

  void _calculateSplits() {
    if (_splitType == SplitType.equal) {
      final amount = widget.totalAmount / widget.group.members.length;
      for (var member in widget.group.members) {
        _controllers[member.id]?.text = amount.toStringAsFixed(2);
      }
    }
  }

  void _onDone() {
    final splitData = <String, double>{};
    for (var member in widget.group.members) {
      splitData[member.id] =
          double.tryParse(_controllers[member.id]!.text) ?? 0;
    }

    // Validation
    if (_splitType == SplitType.percentage) {
      final totalPercentage = splitData.values.reduce((a, b) => a + b);
      if (totalPercentage != 100) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Total percentage must be 100%')),
        );
        return;
      }
    } else if (_splitType == SplitType.custom) {
      final totalAmount = splitData.values.reduce((a, b) => a + b);
      if (totalAmount != widget.totalAmount) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Total amount must match the expense amount')),
        );
        return;
      }
    }

    final splitDetails = SplitDetails(
      transactionId: ' ', // This will be set in the TransactionBloc
      payerMemberId: _payerMemberId!,
      splitType: _splitType,
      splitData: splitData,
    );

    Navigator.of(context).pop(splitDetails);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Split Expense')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Payer selection
            DropdownButtonFormField<String>(
              value: _payerMemberId,
              items: widget.group.members.map((member) {
                return DropdownMenuItem<String>(
                  value: member.id,
                  child: Text(member.name),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _payerMemberId = value;
                });
              },
              decoration: const InputDecoration(labelText: 'Paid by'),
            ),
            const SizedBox(height: 16),
            // Split type selection
            SegmentedButton<SplitType>(
              segments: const [
                ButtonSegment(value: SplitType.equal, label: Text('Equal')),
                ButtonSegment(value: SplitType.percentage, label: Text('%')),
                ButtonSegment(value: SplitType.custom, label: Text('Custom')),
              ],
              selected: {_splitType},
              onSelectionChanged: (selection) {
                setState(() {
                  _splitType = selection.first;
                  _calculateSplits();
                });
              },
            ),
            const SizedBox(height: 16),
            // Members list
            Expanded(
              child: ListView.builder(
                itemCount: widget.group.members.length,
                itemBuilder: (context, index) {
                  final member = widget.group.members[index];
                  return ListTile(
                    title: Text(member.name),
                    trailing: SizedBox(
                      width: 100,
                      child: TextFormField(
                        controller: _controllers[member.id],
                        keyboardType: TextInputType.number,
                        enabled: _splitType != SplitType.equal,
                      ),
                    ),
                  );
                },
              ),
            ),
            ElevatedButton(
              onPressed: _onDone,
              child: const Text('Done'),
            )
          ],
        ),
      ),
    );
  }
}
