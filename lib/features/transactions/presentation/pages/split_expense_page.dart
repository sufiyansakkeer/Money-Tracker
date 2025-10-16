import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:money_track/features/groups/domain/entities/group_entity.dart';
import 'package:money_track/features/groups/bloc/groups_bloc.dart';
import 'package:money_track/features/groups/domain/entities/split_details.dart';

class SplitExpensePage extends StatefulWidget {
  const SplitExpensePage({super.key});

  @override
  State<SplitExpensePage> createState() => _SplitExpensePageState();
}

class _SplitExpensePageState extends State<SplitExpensePage> {
  GroupEntity? _selectedGroup;
  SplitType _splitType = SplitType.equal;
  final _formKey = GlobalKey<FormState>();
  late double _totalAmount;
  final Map<String, double> _splitAmounts = {};

  String? _selectedPayer;

  @override
  void initState() {
    super.initState();
    context.read<GroupsBloc>().add(LoadGroups());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Split Expense'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Total Amount'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the total amount';
                  }
                  return null;
                },
                onSaved: (value) {
                  _totalAmount = double.parse(value!);
                },
              ),
              const SizedBox(height: 16),
              BlocBuilder<GroupsBloc, GroupsState>(
                builder: (context, state) {
                  if (state is GroupsLoading) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  if (state is GroupsLoaded) {
                    return DropdownButtonFormField<GroupEntity>(
                      value: _selectedGroup,
                      items: state.groups.map((group) {
                        return DropdownMenuItem<GroupEntity>(
                          value: group,
                          child: Text(group.name),
                        );
                      }).toList(),
                      onChanged: (group) {
                        setState(() {
                          _selectedGroup = group;
                        });
                      },
                      decoration: const InputDecoration(
                        labelText: 'Select Group',
                      ),
                    );
                  }
                  if (state is GroupsError) {
                    return Center(
                      child: Text(state.message),
                    );
                  }
                  return const Center(
                    child: Text('No groups found.'),
                  );
                },
              ),
              const SizedBox(height: 16),
              if (_selectedGroup != null)
                DropdownButtonFormField<String>(
                  value: _selectedPayer,
                  items: _selectedGroup!.members.map((member) {
                    return DropdownMenuItem<String>(
                      value: member.id,
                      child: Text(member.name),
                    );
                  }).toList(),
                  onChanged: (member) {
                    setState(() {
                      _selectedPayer = member;
                    });
                  },
                  decoration: const InputDecoration(
                    labelText: 'Select Payer',
                  ),
                ),
              const SizedBox(height: 16),
              if (_selectedGroup != null)
                DropdownButtonFormField<SplitType>(
                  value: _splitType,
                  items: SplitType.values.map((type) {
                    return DropdownMenuItem<SplitType>(
                      value: type,
                      child: Text(type.toString().split('.').last),
                    );
                  }).toList(),
                  onChanged: (type) {
                    setState(() {
                      _splitType = type!;
                    });
                  },
                  decoration: const InputDecoration(
                    labelText: 'Split Type',
                  ),
                ),
              const SizedBox(height: 16),
              if (_selectedGroup != null)
                Expanded(
                  child: ListView.builder(
                    itemCount: _selectedGroup!.members.length,
                    itemBuilder: (context, index) {
                      final member = _selectedGroup!.members[index];
                      return ListTile(
                        title: Text(member.name),
                        trailing: _splitType == SplitType.equal
                            ? null
                            : SizedBox(
                                width: 100,
                                child: TextFormField(
                                  decoration: InputDecoration(
                                    labelText:
                                        _splitType == SplitType.percentage
                                            ? 'Percentage'
                                            : 'Amount',
                                  ),
                                  keyboardType: TextInputType.number,
                                  onChanged: (value) {
                                    _splitAmounts[member.id] =
                                        double.parse(value);
                                  },
                                ),
                              ),
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_formKey.currentState!.validate()) {
            _formKey.currentState!.save();

            if (_selectedPayer == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Please select a payer')),
              );
              return;
            }

            Map<String, double> splitData = {};
            if (_splitType == SplitType.equal) {
              final double amountPerMember =
                  _totalAmount / _selectedGroup!.members.length;
              for (var member in _selectedGroup!.members) {
                splitData[member.id] = amountPerMember;
              }
            } else if (_splitType == SplitType.percentage) {
              final double totalPercentage =
                  _splitAmounts.values.fold(0, (a, b) => a + b);
              if (totalPercentage != 100) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('The total percentage must be 100')),
                );
                return;
              }
              for (var member in _selectedGroup!.members) {
                splitData[member.id] =
                    _totalAmount * (_splitAmounts[member.id]! / 100);
              }
            } else if (_splitType == SplitType.custom) {
              final double totalSplitAmount =
                  _splitAmounts.values.fold(0, (a, b) => a + b);
              if (totalSplitAmount != _totalAmount) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text(
                          'The split amounts must equal the total amount')),
                );
                return;
              }
              splitData = _splitAmounts;
            }

            final splitDetails = SplitDetails(
              transactionId: '', // This will be set in the previous screen
              payerMemberId: _selectedPayer!,
              splitType: _splitType,
              splitData: splitData,
            );
            Navigator.pop(context, splitDetails);
          }
        },
        child: const Icon(Icons.check),
      ),
    );
  }
}
