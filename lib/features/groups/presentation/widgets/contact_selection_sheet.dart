import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:money_track/core/constants/colors.dart';
import 'package:money_track/core/utils/sized_box_extension.dart';
import 'package:money_track/features/contact/bloc/contact_bloc.dart';
import 'package:money_track/features/contact/domain/entities/contact_match.dart';
import 'package:money_track/features/groups/domain/entities/group_member.dart';

class ContactSelectionSheet extends StatefulWidget {
  final Function(List<GroupMember>) onContactsSelected;

  const ContactSelectionSheet({
    super.key,
    required this.onContactsSelected,
  });

  @override
  State<ContactSelectionSheet> createState() => _ContactSelectionSheetState();
}

class _ContactSelectionSheetState extends State<ContactSelectionSheet> {
  final Set<String> _selectedContactIds = {};
  List<dynamic> _contactMatches = [];

  @override
  void initState() {
    super.initState();
    context.read<ContactBloc>().add(LoadContactsWithMatching());
  }

  void _toggleContactSelection(String contactId) {
    setState(() {
      if (_selectedContactIds.contains(contactId)) {
        _selectedContactIds.remove(contactId);
      } else {
        _selectedContactIds.add(contactId);
      }
    });
  }

  List<GroupMember> _convertContactsToMembers() {
    return _contactMatches
        .where((match) => _selectedContactIds.contains(match.contact.id))
        .map((match) {
      final contact = match.contact;
      final email =
          contact.emails.isNotEmpty ? contact.emails.first.address : null;
      final phone =
          contact.phones.isNotEmpty ? contact.phones.first.number : null;

      return GroupMember(
        id: contact.id,
        name: contact.displayName,
        email: email,
        phone: phone,
      );
    }).toList();
  }

  void _confirmSelection() {
    final selectedMembers = _convertContactsToMembers();
    widget.onContactsSelected(selectedMembers);
    Navigator.of(context).pop();
  }

  Widget _buildContactTile(dynamic match) {
    final contact = match.contact;
    final status = match.status;
    final isSelected = _selectedContactIds.contains(contact.id);

    // Determine status color and icon
    Color statusColor;
    IconData statusIcon;
    String statusText;

    switch (status) {
      case ContactStatus.existingUser:
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        statusText = 'App User';
        break;
      case ContactStatus.inviteNeeded:
        statusColor = Colors.orange;
        statusIcon = Icons.mail;
        statusText = 'Invite';
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.person;
        statusText = 'Contact';
    }

    return ListTile(
      leading: Stack(
        children: [
          CircleAvatar(
            backgroundColor:
                ColorConstants.getThemeColor(context).withValues(alpha: 0.1),
            child: Text(
              contact.displayName.isNotEmpty
                  ? contact.displayName[0].toUpperCase()
                  : '?',
              style: TextStyle(
                color: ColorConstants.getThemeColor(context),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: statusColor,
                shape: BoxShape.circle,
              ),
              child: Icon(
                statusIcon,
                size: 12,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
      title: Text(
        contact.displayName,
        style: TextStyle(
          color: ColorConstants.getTextColor(context),
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (contact.phones.isNotEmpty)
            Text(
              contact.phones.first.number,
              style: TextStyle(
                color:
                    ColorConstants.getTextColor(context).withValues(alpha: 0.6),
              ),
            ),
          Text(
            statusText,
            style: TextStyle(
              color: statusColor,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
      trailing: Checkbox(
        value: isSelected,
        onChanged: (value) => _toggleContactSelection(contact.id),
        activeColor: ColorConstants.getThemeColor(context),
      ),
      onTap: () => _toggleContactSelection(contact.id),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ContactBloc, ContactState>(
      listener: (context, state) {
        if (state is ContactWithMatchingLoaded) {
          setState(() {
            _contactMatches = state.contactMatches;
          });
        } else if (state is ContactError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error loading contacts: ${state.message}')),
          );
        }
      },
      builder: (context, state) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.8,
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Select Contacts',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: ColorConstants.getTextColor(context),
                    ),
                  ),
                  TextButton(
                    onPressed: _selectedContactIds.isNotEmpty
                        ? _confirmSelection
                        : null,
                    child: Text(
                      'Add (${_selectedContactIds.length})',
                      style: TextStyle(
                        color: _selectedContactIds.isNotEmpty
                            ? ColorConstants.getThemeColor(context)
                            : Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              16.height(),
              if (state is ContactLoading)
                const Expanded(
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (state is ContactWithMatchingLoaded)
                Expanded(
                  child: ListView.builder(
                    itemCount: _contactMatches.length,
                    itemBuilder: (context, index) {
                      final match = _contactMatches[index];
                      return _buildContactTile(match);
                    },
                  ),
                )
              else if (state is ContactError)
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 48,
                          color: Colors.red,
                        ),
                        16.height(),
                        Text(
                          'Failed to load contacts',
                          style: TextStyle(
                            color: ColorConstants.getTextColor(context),
                          ),
                        ),
                        8.height(),
                        Text(
                          state.message,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: ColorConstants.getTextColor(context)
                                .withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                const Expanded(
                  child: Center(child: Text('No contacts available')),
                ),
            ],
          ),
        );
      },
    );
  }
}
