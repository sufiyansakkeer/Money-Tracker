import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:money_track/features/groups/domain/entities/group_entity.dart';
import 'package:money_track/features/groups/domain/usecases/create_group.dart';
import 'package:money_track/features/groups/domain/usecases/delete_group.dart';
import 'package:money_track/features/groups/domain/usecases/get_groups.dart';
import 'package:money_track/features/groups/domain/usecases/get_group_by_id.dart';
import 'package:money_track/features/groups/domain/usecases/update_group.dart'
    as update_group_usecase;

part 'group_event.dart';
part 'group_state.dart';

class GroupBloc extends Bloc<GroupEvent, GroupState> {
  final CreateGroup createGroup;
  final GetGroups getGroups;
  final DeleteGroup deleteGroup;
  final GetGroupById getGroupById;
  final update_group_usecase.UpdateGroup updateGroup;

  GroupBloc({
    required this.createGroup,
    required this.getGroups,
    required this.deleteGroup,
    required this.getGroupById,
    required this.updateGroup,
  }) : super(GroupInitial()) {
    on<LoadGroups>(_onLoadGroups);
    on<CreateGroupEvent>(_onCreateGroup);
    on<UpdateGroupEvent>(_onUpdateGroup);
    on<DeleteGroupEvent>(_onDeleteGroup);
    on<LoadGroupById>(_onLoadGroupById);
  }

  Future<void> _onLoadGroups(LoadGroups event, Emitter<GroupState> emit) async {
    emit(GroupLoading());

    final result = await getGroups.call();

    result.fold(
      (groups) => emit(GroupsLoaded(groups)),
      (failure) => emit(GroupError(failure.message)),
    );
  }

  Future<void> _onCreateGroup(
      CreateGroupEvent event, Emitter<GroupState> emit) async {
    emit(GroupLoading());

    final result = await createGroup.call(params: event.group);

    result.fold(
      (_) {
        emit(GroupCreated());
        add(LoadGroups());
      },
      (failure) => emit(GroupError(failure.message)),
    );
  }

  Future<void> _onUpdateGroup(
      UpdateGroupEvent event, Emitter<GroupState> emit) async {
    emit(GroupLoading());

    final result = await updateGroup.call(params: event.group);

    result.fold(
      (_) {
        emit(GroupUpdated());
        add(LoadGroups());
      },
      (failure) => emit(GroupError(failure.message)),
    );
  }

  Future<void> _onDeleteGroup(
      DeleteGroupEvent event, Emitter<GroupState> emit) async {
    emit(GroupLoading());

    final result = await deleteGroup.call(params: event.groupId);

    result.fold(
      (_) {
        emit(GroupDeleted());
        add(LoadGroups());
      },
      (failure) => emit(GroupError(failure.message)),
    );
  }

  Future<void> _onLoadGroupById(
      LoadGroupById event, Emitter<GroupState> emit) async {
    emit(GroupLoading());

    final result = await getGroupById.call(params: event.groupId);

    result.fold(
      (group) => emit(
          group != null ? GroupLoaded(group) : GroupError('Group not found')),
      (failure) => emit(GroupError(failure.message)),
    );
  }
}
