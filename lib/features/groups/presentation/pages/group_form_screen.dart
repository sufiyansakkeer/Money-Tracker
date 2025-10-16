import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:money_track/features/groups/domain/entities/group_entity.dart';
import 'package:money_track/features/groups/presentation/bloc/group_bloc.dart';
import 'package:uuid/uuid.dart';

class GroupFormScreen extends StatefulWidget {
  const GroupFormScreen({super.key});

  @override
  State<GroupFormScreen> createState() => _GroupFormScreenState();
}

class _GroupFormScreenState extends State<GroupFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final List<GroupMember> _selectedMembers = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Group'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Group Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a group name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _pickContacts,
                child: const Text('Add Members'),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: _selectedMembers.length,
                  itemBuilder: (context, index) {
                    final member = _selectedMembers[index];
                    return ListTile(
                      title: Text(member.name),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createGroup,
        child: const Icon(Icons.check),
      ),
    );
  }

  Future<void> _pickContacts() async {
    if (await FlutterContacts.requestPermission()) {
      final contacts = await FlutterContacts.getContacts(withProperties: true);
      // You can add a UI to select multiple contacts here
      // For simplicity, we'll just add the first contact
      if (contacts.isNotEmpty) {
        final contact = contacts.first;
        setState(() {
          _selectedMembers.add(GroupMember(
            id: const Uuid().v4(),
            name: contact.displayName,
            phone:
                contact.phones.isNotEmpty ? contact.phones.first.number : null,
          ));
        });
      }
    }
  }

  void _createGroup() {
    if (_formKey.currentState!.validate()) {
      final group = GroupEntity(
        id: const Uuid().v4(),
        name: _nameController.text,
        members: _selectedMembers,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      context.read<GroupBloc>().add(CreateGroupEvent(group));
      Navigator.of(context).pop();
    }
  }
}
