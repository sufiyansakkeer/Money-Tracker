import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:money_track/domain/entities/group.dart';
import 'package:money_track/features/contact/bloc/contact_bloc.dart';
import 'package:money_track/features/groups/bloc/groups_bloc.dart';
import 'package:money_track/features/groups/domain/entities/group_entity.dart';

class CreateEditGroupPage extends StatefulWidget {
  final GroupEntity? group;

  const CreateEditGroupPage({super.key, this.group});

  @override
  State<CreateEditGroupPage> createState() => _CreateEditGroupPageState();
}

class _CreateEditGroupPageState extends State<CreateEditGroupPage> {
  final _formKey = GlobalKey<FormState>();
  late String _groupName = '';
  List<GroupMember> _selectedContacts = [];

  @override
  void initState() {
    super.initState();
    if (widget.group != null) {
      _groupName = widget.group!.name;
      _selectedContacts = List<GroupMember>.from(widget.group!.members);
    }
    context.read<ContactBloc>().add(LoadContacts());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.group == null ? 'Create Group' : 'Edit Group'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                initialValue: _groupName,
                decoration: const InputDecoration(labelText: 'Group Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a group name';
                  }
                  return null;
                },
                onSaved: (value) {
                  _groupName = value!;
                },
              ),
              const SizedBox(height: 16),
              Expanded(
                child: BlocBuilder<ContactBloc, ContactState>(
                  builder: (context, state) {
                    if (state is ContactLoading) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                    if (state is ContactLoaded) {
                      return ListView.builder(
                        itemCount: state.contacts.length,
                        itemBuilder: (context, index) {
                          final contact = state.contacts[index];
                          return CheckboxListTile(
                            title: Text(contact.displayName),
                            value:
                                _selectedContacts.any((m) => m.id == contact.id),
                            onChanged: (value) {
                              setState(() {
                                if (value!) {
                                  _selectedContacts.add(
                                    GroupMember(
                                      id: contact.id,
                                      name: contact.displayName,
                                      email: contact.emails.isNotEmpty
                                          ? contact.emails.first.address
                                          : null,
                                      phone: contact.phones.isNotEmpty
                                          ? contact.phones.first.number
                                          : null,
                                    ),
                                  );
                                } else {
                                  _selectedContacts
                                      .removeWhere((m) => m.id == contact.id);
                                }
                              });
                            },
                          );
                        },
                      );
                    }
                    if (state is ContactError) {
                      return Center(
                        child: Text(state.message),
                      );
                    }
                    return const Center(
                      child: Text('No contacts found.'),
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
            final now = DateTime.now();
            final group = GroupEntity(
              id: widget.group?.id ?? now.toIso8601String(),
              name: _groupName,
              members: _selectedContacts,
              createdAt: widget.group?.createdAt ?? now,
              updatedAt: now,
            );
            if (widget.group == null) {
              context.read<GroupsBloc>().add(AddGroup(group));
            } else {
              context.read<GroupsBloc>().add(UpdateGroup(group));
            }
            Navigator.pop(context);
          }
        },
        child: const Icon(Icons.check),
      ),
    );
  }
}
