import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:money_track/features/groups/presentation/bloc/group_bloc.dart';

class GroupListScreen extends StatefulWidget {
  const GroupListScreen({super.key});

  @override
  State<GroupListScreen> createState() => _GroupListScreenState();
}

class _GroupListScreenState extends State<GroupListScreen> {
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
      appBar: AppBar(
        title: const Text('Groups'),
      ),
      body: BlocBuilder<GroupBloc, GroupState>(
        builder: (context, state) {
          if (state is GroupLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is GroupsLoaded) {
            return ListView.builder(
              itemCount: state.groups.length,
              itemBuilder: (context, index) {
                final group = state.groups[index];
                return ListTile(
                  title: Text(group.name),
                  subtitle: Text('${group.members.length} members'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      context.read<GroupBloc>().add(DeleteGroupEvent(group.id));
                    },
                  ),
                );
              },
            );
          } else if (state is GroupError) {
            return Center(child: Text(state.message));
          }
          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to GroupFormScreen
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
