part of 'group_bloc.dart';

abstract class GroupEvent extends Equatable {
  const GroupEvent();

  @override
  List<Object?> get props => [];
}

class LoadGroups extends GroupEvent {}

class LoadGroupById extends GroupEvent {
  final String groupId;

  const LoadGroupById(this.groupId);

  @override
  List<Object?> get props => [groupId];
}

class CreateGroupEvent extends GroupEvent {
  final GroupEntity group;

  const CreateGroupEvent(this.group);

  @override
  List<Object?> get props => [group];
}

class UpdateGroupEvent extends GroupEvent {
  final GroupEntity group;

  const UpdateGroupEvent(this.group);

  @override
  List<Object?> get props => [group];
}

class DeleteGroupEvent extends GroupEvent {
  final String groupId;

  const DeleteGroupEvent(this.groupId);

  @override
  List<Object?> get props => [groupId];
}