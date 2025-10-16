import 'package:money_track/features/navigation/domain/entities/rive_entity.dart';

class NavItemModel {
  final String text;
  final RiveEntity rive;

  NavItemModel({
    required this.text,
    required this.rive,
  });
}

List<NavItemModel> bottomNavItems = [
  NavItemModel(
    text: "Home",
    rive: RiveEntity(
      src: "assets/rive/animated_icon_rive.riv",
      artBoard: "HOME",
      stateMachineName: "HOME_interactivity",
    ),
  ),
  NavItemModel(
    text: "Categories",
    rive: RiveEntity(
      src: "assets/rive/animated_icon_rive.riv",
      artBoard: "LIKE/STAR",
      stateMachineName: "STAR_Interactivity",
    ),
  ),
  NavItemModel(
    text: "Profile",
    rive: RiveEntity(
      src: "assets/rive/animated_icon_rive.riv",
      artBoard: "USER",
      stateMachineName: "USER_Interactivity",
    ),
  ),
];
