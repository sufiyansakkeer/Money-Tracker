import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:money_track/core/logging/app_logger.dart';
import 'package:money_track/features/categories/presentation/pages/category_page.dart';
import 'package:money_track/features/transactions/presentation/pages/home/home_page.dart';
import 'package:money_track/features/profile/presentation/pages/profile_page.dart';

part 'bottom_navigation_event.dart';
part 'bottom_navigation_state.dart';

class BottomNavigationBloc
    extends Bloc<BottomNavigationEvent, BottomNavigationState> {
  BottomNavigationBloc() : super(BottomNavigationState(index: 0)) {
    AppLogger().info('BottomNavigationBloc initialized', tag: 'BOTTOM_NAV_BLOC');
    
    on<ChangeBottomNavigationEvent>(
      (event, emit) {
        final previousIndex = state.index;
        final newIndex = event.index;
        
        AppLogger().navigation(
          'Tab$previousIndex', 
          'Tab$newIndex',
          arguments: {'previousIndex': previousIndex, 'newIndex': newIndex}
        );
        
        emit(BottomNavigationState(index: newIndex));
      },
    );
  }
}