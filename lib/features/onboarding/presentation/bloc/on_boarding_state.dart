part of 'on_boarding_cubit.dart';

class OnBoardingState extends Equatable {
  final int currentPage;

  const OnBoardingState({required this.currentPage});

  @override
  List<Object> get props => [currentPage];
}
