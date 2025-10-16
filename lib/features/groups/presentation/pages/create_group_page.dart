import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:money_track/core/constants/colors.dart';
import 'package:money_track/core/constants/style_constants.dart';
import 'package:money_track/core/utils/sized_box_extension.dart';
import 'package:money_track/core/utils/snack_bar_extension.dart';
import 'package:money_track/features/contact/bloc/contact_bloc.dart';
import 'package:money_track/features/groups/domain/entities/group_entity.dart';
import 'package:money_track/features/groups/presentation/bloc/group_bloc.dart';

class CreateGroupPage extends StatefulWidget {
  const CreateGroupPage({super.key});

  @override
  State<CreateGroupPage> createState() => _CreateGroupPageState();
}

class _CreateGroupPageState extends State<CreateGroupPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final List<GroupMember> _selectedMembers = [];

  @override
  void initState() {
    super.initState();
    context.read<ContactBloc>().add(LoadContacts());
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _createGroup() {
    if (_formKey.currentState!.validate()) {
      if (_selectedMembers.isEmpty) {
        'Please add at least one member'.showSnack();
        return;
      }

      // Validate group name is not just whitespace
      if (_nameController.text.trim().isEmpty) {
        'Group name cannot be empty'.showSnack();
        return;
      }

      // Validate member names are not empty
      for (final member in _selectedMembers) {
        if (member.name.trim().isEmpty) {
          'Member names cannot be empty'.showSnack();
          return;
        }
      }

      final group = GroupEntity(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        members: _selectedMembers,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      context.read<GroupBloc>().add(CreateGroupEvent(group));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Group'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: BlocListener<GroupBloc, GroupState>(
        listener: (context, state) {
          if (state is GroupCreated) {
            'Group created successfully'
                .showSnack(backgroundColor: Colors.green);
            Navigator.of(context).pop();
          } else if (state is GroupError) {
            state.message.showSnack();
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Group Name
                Text(
                  'Group Name',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: ColorConstants.getTextColor(context)
                        .withValues(alpha: 0.6),
                  ),
                ),
                8.height(),
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    hintText: 'Enter group name',
                    prefixIcon: const Icon(Icons.group),
                    border: StyleConstants.textFormFieldBorder(),
                    enabledBorder: StyleConstants.textFormFieldBorder(),
                    focusedBorder:
                        StyleConstants.textFormFieldBorder().copyWith(
                      borderSide: BorderSide(
                        color: ColorConstants.getThemeColor(context),
                        width: 2,
                      ),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a group name';
                    }
                    return null;
                  },
                ),
                16.height(),

                // Description
                Text(
                  'Description (Optional)',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: ColorConstants.getTextColor(context)
                        .withValues(alpha: 0.6),
                  ),
                ),
                8.height(),
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'Enter group description',
                    prefixIcon: const Icon(Icons.description),
                    border: StyleConstants.textFormFieldBorder(),
                    enabledBorder: StyleConstants.textFormFieldBorder(),
                    focusedBorder:
                        StyleConstants.textFormFieldBorder().copyWith(
                      borderSide: BorderSide(
                        color: ColorConstants.getThemeColor(context),
                        width: 2,
                      ),
                    ),
                  ),
                ),
                16.height(),

                // Members Section
                Row(
                  children: [
                    Text(
                      'Members',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: ColorConstants.getTextColor(context)
                            .withValues(alpha: 0.6),
                      ),
                    ),
                    const Spacer(),
                    TextButton.icon(
                      onPressed: _showAddMemberDialog,
                      icon: const Icon(Icons.add),
                      label: const Text('Add Member'),
                    ),
                  ],
                ),
                8.height(),

                // Selected Members List
                if (_selectedMembers.isNotEmpty) ...[
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _selectedMembers.length,
                      separatorBuilder: (context, index) =>
                          const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final member = _selectedMembers[index];
                        return ListTile(
                          leading: CircleAvatar(
                            child: Text(member.name[0].toUpperCase()),
                          ),
                          title: Text(member.name),
                          subtitle:
                              member.email != null ? Text(member.email!) : null,
                          trailing: IconButton(
                            icon: const Icon(Icons.remove_circle,
                                color: Colors.red),
                            onPressed: () {
                              setState(() {
                                _selectedMembers.removeAt(index);
                              });
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ] else ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.group_add,
                          size: 48,
                          color: Colors.grey[400],
                        ),
                        8.height(),
                        Text(
                          'No members added yet',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                ],

                const Spacer(),

                // Create Button
                BlocBuilder<GroupBloc, GroupState>(
                  builder: (context, state) {
                    return SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: state is GroupLoading ? null : _createGroup,
                        style: StyleConstants.elevatedButtonStyle(
                            context: context),
                        child: state is GroupLoading
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
                                'Create Group',
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
    );
  }

  void _showAddMemberDialog() {
    showDialog(
      context: context,
      builder: (context) => _AddMemberDialog(
        onMemberAdded: (member) {
          setState(() {
            _selectedMembers.add(member);
          });
        },
        existingMembers: _selectedMembers,
      ),
    );
  }
}

class _AddMemberDialog extends StatefulWidget {
  final Function(GroupMember) onMemberAdded;
  final List<GroupMember> existingMembers;

  const _AddMemberDialog({
    required this.onMemberAdded,
    required this.existingMembers,
  });

  @override
  State<_AddMemberDialog> createState() => _AddMemberDialogState();
}

class _AddMemberDialogState extends State<_AddMemberDialog> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Member'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Name',
              hintText: 'Enter member name',
            ),
          ),
          16.height(),
          TextField(
            controller: _emailController,
            decoration: const InputDecoration(
              labelText: 'Email (Optional)',
              hintText: 'Enter member email',
            ),
            keyboardType: TextInputType.emailAddress,
          ),
          16.height(),
          BlocBuilder<ContactBloc, ContactState>(
            builder: (context, state) {
              if (state is ContactLoaded && state.contacts.isNotEmpty) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Or select from contacts:'),
                    8.height(),
                    SizedBox(
                      height: 150,
                      child: ListView.builder(
                        itemCount: state.contacts.length,
                        itemBuilder: (context, index) {
                          final contact = state.contacts[index];
                          return ListTile(
                            title: Text(contact.displayName),
                            subtitle: contact.emails.isNotEmpty
                                ? Text(contact.emails.first.address)
                                : null,
                            onTap: () {
                              _nameController.text = contact.displayName;
                              if (contact.emails.isNotEmpty) {
                                _emailController.text =
                                    contact.emails.first.address;
                              }
                            },
                          );
                        },
                      ),
                    ),
                  ],
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            if (_nameController.text.trim().isNotEmpty) {
              final member = GroupMember(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                name: _nameController.text.trim(),
                email: _emailController.text.trim().isEmpty
                    ? null
                    : _emailController.text.trim(),
              );

              widget.onMemberAdded(member);
              Navigator.of(context).pop();
            }
          },
          child: const Text('Add'),
        ),
      ],
    );
  }
}
