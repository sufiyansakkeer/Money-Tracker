import 'package:flutter/material.dart';
import 'package:money_track/core/constants/colors.dart';
import 'package:money_track/core/utils/sized_box_extension.dart';
import 'package:money_track/features/groups/domain/entities/group_member.dart';

class UserSearchSheet extends StatefulWidget {
  final Function(List<GroupMember>) onUsersSelected;

  const UserSearchSheet({
    super.key,
    required this.onUsersSelected,
  });

  @override
  State<UserSearchSheet> createState() => _UserSearchSheetState();
}

class _UserSearchSheetState extends State<UserSearchSheet> {
  final TextEditingController _searchController = TextEditingController();
  final Set<String> _selectedUserIds = {};
  List<Map<String, String>> _searchResults = [];

  // Mock user data - replace with actual API call
  final List<Map<String, String>> _mockUsers = [
    {'id': '1', 'name': 'Alice Johnson', 'email': 'alice@example.com'},
    {'id': '2', 'name': 'Bob Smith', 'email': 'bob@example.com'},
    {'id': '3', 'name': 'Charlie Brown', 'email': 'charlie@example.com'},
    {'id': '4', 'name': 'Diana Prince', 'email': 'diana@example.com'},
    {'id': '5', 'name': 'Eve Wilson', 'email': 'eve@example.com'},
  ];

  void _searchUsers(String query) {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
      });
      return;
    }

    // Filter mock users based on search query
    final results = _mockUsers.where((user) {
      final name = user['name']!.toLowerCase();
      final email = user['email']!.toLowerCase();
      final searchQuery = query.toLowerCase();
      return name.contains(searchQuery) || email.contains(searchQuery);
    }).toList();

    setState(() {
      _searchResults = results;
    });
  }

  void _toggleUserSelection(String userId) {
    setState(() {
      if (_selectedUserIds.contains(userId)) {
        _selectedUserIds.remove(userId);
      } else {
        _selectedUserIds.add(userId);
      }
    });
  }

  List<GroupMember> _convertUsersToMembers() {
    return _searchResults
        .where((user) => _selectedUserIds.contains(user['id']))
        .map((user) => GroupMember(
              id: user['id']!,
              name: user['name']!,
              email: user['email'],
            ))
        .toList();
  }

  void _confirmSelection() {
    final selectedMembers = _convertUsersToMembers();
    widget.onUsersSelected(selectedMembers);
    Navigator.of(context).pop();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Search Users',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: ColorConstants.getTextColor(context),
                ),
              ),
              TextButton(
                onPressed:
                    _selectedUserIds.isNotEmpty ? _confirmSelection : null,
                child: Text(
                  'Add (${_selectedUserIds.length})',
                  style: TextStyle(
                    color: _selectedUserIds.isNotEmpty
                        ? ColorConstants.getThemeColor(context)
                        : Colors.grey,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          16.height(),
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search by username or email',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor:
                  ColorConstants.getTextColor(context).withValues(alpha: 0.05),
            ),
            onChanged: _searchUsers,
          ),
          16.height(),
          Expanded(
            child: _searchResults.isEmpty && _searchController.text.isNotEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 48,
                          color: ColorConstants.getTextColor(context)
                              .withValues(alpha: 0.3),
                        ),
                        16.height(),
                        Text(
                          'No users found',
                          style: TextStyle(
                            color: ColorConstants.getTextColor(context)
                                .withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                  )
                : _searchResults.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.person_search,
                              size: 48,
                              color: ColorConstants.getTextColor(context)
                                  .withValues(alpha: 0.3),
                            ),
                            16.height(),
                            Text(
                              'Start typing to search users',
                              style: TextStyle(
                                color: ColorConstants.getTextColor(context)
                                    .withValues(alpha: 0.6),
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: _searchResults.length,
                        itemBuilder: (context, index) {
                          final user = _searchResults[index];
                          final isSelected =
                              _selectedUserIds.contains(user['id']);

                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor:
                                  ColorConstants.getThemeColor(context)
                                      .withValues(alpha: 0.1),
                              child: Text(
                                user['name']![0].toUpperCase(),
                                style: TextStyle(
                                  color: ColorConstants.getThemeColor(context),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            title: Text(
                              user['name']!,
                              style: TextStyle(
                                color: ColorConstants.getTextColor(context),
                              ),
                            ),
                            subtitle: Text(
                              user['email']!,
                              style: TextStyle(
                                color: ColorConstants.getTextColor(context)
                                    .withValues(alpha: 0.6),
                              ),
                            ),
                            trailing: Checkbox(
                              value: isSelected,
                              onChanged: (value) =>
                                  _toggleUserSelection(user['id']!),
                              activeColor:
                                  ColorConstants.getThemeColor(context),
                            ),
                            onTap: () => _toggleUserSelection(user['id']!),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
