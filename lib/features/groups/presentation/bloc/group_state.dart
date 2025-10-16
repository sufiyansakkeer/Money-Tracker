part of 'group_bloc.dart';

abstract class GroupState extends Equatable {
  const GroupState();

  @override
  List<Object?> get props => [];
}

class GroupInitial extends GroupState {}

class GroupLoading extends GroupState {}

class GroupsLoaded extends GroupState {
  final List<GroupEntity> groups;

  const GroupsLoaded(this.groups);

  @override
  List<Object?> get props => [groups];
}

class GroupLoaded extends GroupState {
  final GroupEntity group;

  const GroupLoaded(this.group);

  @override
  List<Object?> get props => [group];
}

class GroupCreated extends GroupState {}

class GroupUpdated extends GroupState {}

class GroupDeleted extends GroupState {}

class GroupError extends GroupState {
  final String message;

  const GroupError(this.message);

  @override
  List<Object?> get props => [message];
}