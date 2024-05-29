part of 'bottom_navigation_bloc.dart';

@immutable
sealed class BottomNavigationEvent {}

class ChangeBottomNavigation extends BottomNavigationEvent {
  final int index;

  ChangeBottomNavigation({required this.index});
}
