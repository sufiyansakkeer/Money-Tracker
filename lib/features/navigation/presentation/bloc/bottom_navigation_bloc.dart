import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:money_track/features/categories/presentation/pages/categories_groups_page.dart';
import 'package:money_track/features/transactions/presentation/pages/home/home_page.dart';
import 'package:money_track/features/profile/presentation/pages/profile_page.dart';

part 'bottom_navigation_event.dart';
part 'bottom_navigation_state.dart';

class BottomNavigationBloc
    extends Bloc<BottomNavigationEvent, BottomNavigationState> {
  BottomNavigationBloc() : super(BottomNavigationState(index: 0)) {
    on<ChangeBottomNavigationEvent>(
      (event, emit) {
        final newIndex = event.index;
        emit(BottomNavigationState(index: newIndex));
      },
    );
  }
}
