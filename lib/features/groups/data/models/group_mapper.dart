import 'package:money_track/features/groups/data/models/group_member_model.dart';
import 'package:money_track/features/groups/data/models/group_model.dart';
import 'package:money_track/features/groups/domain/entities/group_entity.dart';

extension GroupEntityMapper on GroupEntity {
  GroupModel toModel() {
    return GroupModel(
      id: id,
      name: name,
      members: members.map((member) => member.toModel()).toList(),
      createdAt: createdAt,
      updatedAt: updatedAt,
      description: description,
    );
  }
}

extension GroupMemberMapper on GroupMember {
  GroupMemberModel toModel() {
    return GroupMemberModel(
      id: id,
      name: name,
      email: email,
      phone: phone,
    );
  }
}

extension GroupModelMapper on GroupModel {
  GroupEntity toEntity() {
    return GroupEntity(
      id: id,
      name: name,
      members: members.map((member) => member.toEntity()).toList(),
      createdAt: createdAt,
      updatedAt: updatedAt,
      description: description,
    );
  }
}

extension GroupMemberModelMapper on GroupMemberModel {
  GroupMember toEntity() {
    return GroupMember(
      id: id,
      name: name,
      email: email,
      phone: phone,
    );
  }
}
