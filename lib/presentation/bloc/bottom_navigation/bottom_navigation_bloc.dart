import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:money_track/presentation/pages/category/category_page.dart';
// import 'package:money_track/presentation/pages/home/home_page.dart';
import 'package:money_track/presentation/pages/profile/profile_page.dart';

part 'bottom_navigation_event.dart';
part 'bottom_navigation_state.dart';

class BottomNavigationBloc
    extends Bloc<BottomNavigationEvent, BottomNavigationState> {
  BottomNavigationBloc() : super(BottomNavigationState(index: 0)) {
    on<ChangeBottomNavigation>(
      (event, emit) => emit(
        BottomNavigationState(index: event.index),
      ),
    );
  }
}
