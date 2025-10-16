import 'package:equatable/equatable.dart';
import './group_member.dart';

class Group extends Equatable {
  final String id;
  final String name;
  final List<GroupMember> members;

  const Group({required this.id, required this.name, required this.members});

  @override
  List<Object?> get props => [id, name, members];
}
