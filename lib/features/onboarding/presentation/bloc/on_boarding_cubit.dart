import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

part 'on_boarding_state.dart';

class OnBoardingCubit extends Cubit<OnBoardingState> {
  OnBoardingCubit() : super(const OnBoardingState(currentPage: 0));

  void changePage(int page) {
    emit(OnBoardingState(currentPage: page));
  }
}
