part of 'groups_bloc.dart';

abstract class GroupsEvent extends Equatable {
  const GroupsEvent();

  @override
  List<Object> get props => [];
}

class LoadGroups extends GroupsEvent {}

class AddGroup extends GroupsEvent {
  final GroupEntity group;

  const AddGroup(this.group);

  @override
  List<Object> get props => [group];
}

class UpdateGroup extends GroupsEvent {
  final GroupEntity group;

  const UpdateGroup(this.group);

  @override
  List<Object> get props => [group];
}

class DeleteGroup extends GroupsEvent {
  final String groupId;

  const DeleteGroup(this.groupId);

  @override
  List<Object> get props => [groupId];
}
