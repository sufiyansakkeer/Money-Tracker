import 'package:hive_ce/hive.dart';
import './group_member_model.dart';
import '../../domain/entities/group_entity.dart';

part 'group_model.g.dart';

@HiveType(typeId: 8)
class GroupModel {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String name;
  @HiveField(2)
  final List<GroupMemberModel> members;
  @HiveField(3)
  final DateTime createdAt;
  @HiveField(4)
  final DateTime updatedAt;
  @HiveField(5)
  final String? description;

  GroupModel({
    required this.id,
    required this.name,
    required this.members,
    required this.createdAt,
    required this.updatedAt,
    this.description,
  });

  factory GroupModel.fromEntity(GroupEntity entity) {
    return GroupModel(
      id: entity.id,
      name: entity.name,
      members: entity.members.map((m) => GroupMemberModel(
        id: m.id,
        name: m.name,
        email: m.email,
        phone: m.phone,
      )).toList(),
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      description: entity.description,
    );
  }

  GroupEntity toEntity() {
    return GroupEntity(
      id: id,
      name: name,
      members: members.map((m) => GroupMember(
        id: m.id,
        name: m.name,
        email: m.email,
        phone: m.phone,
      )).toList(),
      createdAt: createdAt,
      updatedAt: updatedAt,
      description: description,
    );
  }
}