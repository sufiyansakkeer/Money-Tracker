import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:money_track/features/groups/domain/entities/group_entity.dart';
import 'package:money_track/features/groups/domain/repositories/group_repository.dart';

part 'groups_event.dart';
part 'groups_state.dart';

class GroupsBloc extends Bloc<GroupsEvent, GroupsState> {
  final GroupRepository _groupRepository;

  GroupsBloc(this._groupRepository) : super(GroupsInitial()) {
    on<LoadGroups>((event, emit) async {
      emit(GroupsLoading());
      final result = await _groupRepository.getGroups();
      result.fold(
        (groups) => emit(GroupsLoaded(groups)),
        (failure) => emit(GroupsError(failure.message)),
      );
    });

    on<AddGroup>((event, emit) async {
      final result = await _groupRepository.createGroup(event.group);
      result.fold(
        (_) async {
          final groupsResult = await _groupRepository.getGroups();
          groupsResult.fold(
            (groups) => emit(GroupsLoaded(groups)),
            (failure) => emit(GroupsError(failure.message)),
          );
        },
        (failure) => emit(GroupsError(failure.message)),
      );
    });

    on<UpdateGroup>((event, emit) async {
      final result = await _groupRepository.updateGroup(event.group);
      result.fold(
        (_) async {
          final groupsResult = await _groupRepository.getGroups();
          groupsResult.fold(
            (groups) => emit(GroupsLoaded(groups)),
            (failure) => emit(GroupsError(failure.message)),
          );
        },
        (failure) => emit(GroupsError(failure.message)),
      );
    });

    on<DeleteGroup>((event, emit) async {
      final result = await _groupRepository.deleteGroup(event.groupId);
      result.fold(
        (_) async {
          final groupsResult = await _groupRepository.getGroups();
          groupsResult.fold(
            (groups) => emit(GroupsLoaded(groups)),
            (failure) => emit(GroupsError(failure.message)),
          );
        },
        (failure) => emit(GroupsError(failure.message)),
      );
    });
  }
}
