import 'package:money_track/domain/bottom_navigation/rive.dart';

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
    text: "Chat",
    rive: RiveModel(
      src: "assets/rive/animated_icon_rive.riv",
      artBoard: "CHAT",
      stateMachineName: "CHAT_Interactivity",
    ),
  ),
  NavItemModel(
    text: "user",
    rive: RiveModel(
      src: "assets/rive/animated_icon_rive.riv",
      artBoard: "USER",
      stateMachineName: "USER_Interactivity",
    ),
  ),
];
