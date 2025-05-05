part of 'bottom_navigation_bloc.dart';

abstract class BottomNavigationEvent {}

class ChangeBottomNavigationEvent extends BottomNavigationEvent {
  final int index;

  ChangeBottomNavigationEvent({required this.index});
}
