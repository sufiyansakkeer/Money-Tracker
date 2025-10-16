import 'package:hive_ce/hive.dart';

part 'group_member_model.g.dart';

@HiveType(typeId: 10)
class GroupMemberModel {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String name;
  @HiveField(2)
  final String? email;
  @HiveField(3)
  final String? phone;

  GroupMemberModel({
    required this.id,
    required this.name,
    this.email,
    this.phone,
  });

  factory GroupMemberModel.fromJson(Map<String, dynamic> json) {
    return GroupMemberModel(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
    };
  }
}