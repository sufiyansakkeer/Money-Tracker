import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:money_track/core/constants/colors.dart';
import 'package:money_track/core/utils/navigation_extension.dart';
import 'package:money_track/core/utils/sized_box_extension.dart';
import 'package:money_track/features/groups/domain/entities/group_entity.dart';
import 'package:money_track/features/groups/domain/entities/group_member.dart';
import 'package:money_track/features/groups/presentation/bloc/group_bloc.dart';

class GroupBottomSheetWidget extends StatefulWidget {
  const GroupBottomSheetWidget({super.key});

  @override
  State<GroupBottomSheetWidget> createState() => _GroupBottomSheetWidgetState();
}

class _GroupBottomSheetWidgetState extends State<GroupBottomSheetWidget> {
  late GlobalKey<FormState> _formKey;
  late TextEditingController _nameController;
  late TextEditingController _memberController;
  final List<String> _members = [];

  @override
  void initState() {
    super.initState();
    _formKey = GlobalKey<FormState>();
    _nameController = TextEditingController();
    _memberController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _memberController.dispose();
    super.dispose();
  }

  void _addMember() {
    if (_memberController.text.trim().isNotEmpty) {
      setState(() {
        _members.add(_memberController.text.trim());
        _memberController.clear();
      });
    }
  }

  void _removeMember(int index) {
    setState(() {
      _members.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Create Group",
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 16,
                color: ColorConstants.getTextColor(context),
              ),
            ),
            20.height(),
            Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(16)),
                        ),
                        hintText: "Group Name",
                        prefixIcon: Icon(Icons.group),
                      ),
                      validator: (value) {
                        if (value == null ||
                            value.isEmpty ||
                            value.trim() == "") {
                          return "Group name is required";
                        }
                        return null;
                      },
                    ),
                    16.height(),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _memberController,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(16)),
                              ),
                              hintText: "Member Name",
                              prefixIcon: Icon(Icons.person),
                            ),
                            onFieldSubmitted: (_) => _addMember(),
                          ),
                        ),
                        8.width(),
                        IconButton(
                          onPressed: _addMember,
                          icon: Icon(
                            Icons.add_circle,
                            color: ColorConstants.getThemeColor(context),
                          ),
                        ),
                      ],
                    ),
                    if (_members.isNotEmpty) ...[
                      16.height(),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          border: Border.all(
                              color: Colors.grey.withValues(alpha: 0.3)),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Members (${_members.length})",
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                            8.height(),
                            Wrap(
                              spacing: 8,
                              runSpacing: 4,
                              children: _members.asMap().entries.map((entry) {
                                int index = entry.key;
                                String member = entry.value;
                                return Chip(
                                  label: Text(member),
                                  deleteIcon: const Icon(Icons.close, size: 18),
                                  onDeleted: () => _removeMember(index),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            20.height(),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorConstants.getThemeColor(context),
                minimumSize: const Size(double.infinity, 55),
                enableFeedback: true,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  final groupMembers = _members
                      .map((name) => GroupMember(
                            id: DateTime.now()
                                    .millisecondsSinceEpoch
                                    .toString() +
                                name.hashCode.toString(),
                            name: name,
                          ))
                      .toList();

                  final group = GroupEntity(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    name: _nameController.text.trim(),
                    members: groupMembers,
                    createdAt: DateTime.now(),
                    updatedAt: DateTime.now(),
                  );

                  context.read<GroupBloc>().add(CreateGroupEvent(group));
                  context.pop();
                }
              },
              child: const Text(
                "Create Group",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            30.height(),
          ],
        ),
      ),
    );
  }
}
