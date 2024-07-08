import 'package:flutter_bloc/flutter_bloc.dart';

part 'on_boarding_state.dart';

class OnBoardingCubit extends Cubit<OnBoardingState> {
  OnBoardingCubit() : super(OnBoardingState(index: 0));

  changeIndex({required int index}) {
    emit(OnBoardingState(index: index));
  }
}
