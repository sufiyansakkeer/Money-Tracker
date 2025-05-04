import 'package:flutter/material.dart';

class ProfileModel {
  final String title;
  final String subtitle;
  final Widget? navigationScreen;
  final void Function()? onPressed;
  final String? tag;
  final IconData? icon; // Added icon property

  ProfileModel({
    required this.title,
    required this.subtitle,
    required this.navigationScreen,
    this.onPressed,
    this.tag,
    this.icon, // Added icon parameter
  });
}
