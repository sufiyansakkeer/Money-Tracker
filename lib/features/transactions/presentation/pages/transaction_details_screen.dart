import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:money_track/domain/entities/transaction_entity.dart';
import 'package:money_track/features/groups/domain/entities/group_entity.dart';
import 'package:money_track/features/groups/presentation/bloc/group_bloc.dart';

class TransactionDetailsScreen extends StatefulWidget {
  final TransactionEntity transaction;

  const TransactionDetailsScreen({super.key, required this.transaction});

  @override
  State<TransactionDetailsScreen> createState() =>
      _TransactionDetailsScreenState();
}

class _TransactionDetailsScreenState extends State<TransactionDetailsScreen> {
  @override
  void initState() {
    super.initState();
    // Load groups when the screen is initialized after the widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GroupBloc>().add(LoadGroups());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Transaction Details')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Amount: ${widget.transaction.amount}'),
            Text('Category: ${widget.transaction.category.categoryName}'),
            Text('Date: ${widget.transaction.date}'),
            if (widget.transaction.groupId != null)
              BlocBuilder<GroupBloc, GroupState>(
                builder: (context, state) {
                  if (state is GroupsLoaded) {
                    final group = state.groups.firstWhere(
                        (g) => g.id == widget.transaction.groupId,
                        orElse: () => GroupEntity(
                            id: '',
                            name: '',
                            members: [],
                            createdAt: DateTime.now(),
                            updatedAt: DateTime.now()));
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 16),
                        Text('Group: ${group.name}'),
                        const SizedBox(height: 8),
                        Text('Split among ${group.members.length} members:'),
                        ...group.members.map((member) => Padding(
                              padding: const EdgeInsets.only(left: 16, top: 4),
                              child: Text('• ${member.name}'),
                            ))
                      ],
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
          ],
        ),
      ),
    );
  }
}
