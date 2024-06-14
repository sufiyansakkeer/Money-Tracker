part of 'bottom_navigation_bloc.dart';

class BottomNavigationState {
  final int index;

  final pages = [
    const HomePage(),
    const CategoryPage(),
    const SettingsPage(),
  ];
  BottomNavigationState({required this.index});
}
