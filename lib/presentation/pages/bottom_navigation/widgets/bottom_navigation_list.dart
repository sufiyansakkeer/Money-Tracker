import 'package:money_track/models/bottom_navigation/rive.dart';

class NavItemModel {
  final String text;
  final RiveModel rive;

  NavItemModel({
    required this.text,
    required this.rive,
  });
}

List<NavItemModel> bottomNavItems = [
  NavItemModel(
    text: "Home",
    rive: RiveModel(
      src: "assets/rive/animated_icon_rive.riv",
      artBoard: "HOME",
      stateMachineName: "HOME_interactivity",
    ),
  ),
  NavItemModel(
    text: "Category",
    rive: RiveModel(
      src: "assets/rive/animated_icon_rive.riv",
      artBoard: "LIKE/STAR",
      stateMachineName: "STAR_Interactivity",
    ),
  ),
  NavItemModel(
    text: "Profile",
    rive: RiveModel(
      src: "assets/rive/animated_icon_rive.riv",
      artBoard: "USER",
      stateMachineName: "USER_Interactivity",
    ),
  ),
];
