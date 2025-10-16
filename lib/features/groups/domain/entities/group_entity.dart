import 'package:equatable/equatable.dart';

class GroupMember extends Equatable {
  final String id;
  final String name;
  final String? email;
  final String? phone;

  const GroupMember({
    required this.id,
    required this.name,
    this.email,
    this.phone,
  });

  @override
  List<Object?> get props => [id, name, email, phone];
}

class GroupEntity extends Equatable {
  final String id;
  final String name;
  final List<GroupMember> members;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? description;

  const GroupEntity({
    required this.id,
    required this.name,
    required this.members,
    required this.createdAt,
    required this.updatedAt,
    this.description,
  });

  @override
  List<Object?> get props => [id, name, members, createdAt, updatedAt, description];

  GroupEntity copyWith({
    String? id,
    String? name,
    List<GroupMember>? members,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? description,
  }) {
    return GroupEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      members: members ?? this.members,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      description: description ?? this.description,
    );
  }
}