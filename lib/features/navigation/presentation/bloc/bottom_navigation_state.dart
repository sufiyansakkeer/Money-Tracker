part of 'bottom_navigation_bloc.dart';

class BottomNavigationState {
  final int index;

  final pages = [
    const HomePage(),
    const CategoriesGroupsPage(),
    const ProfilePage(),
  ];
  
  BottomNavigationState({required this.index});
}
