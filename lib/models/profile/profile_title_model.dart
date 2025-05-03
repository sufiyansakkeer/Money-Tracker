import 'package:flutter/material.dart';

class ProfileModel {
  final String title;
  final String subtitle;
  final Widget? navigationScreen;
  final void Function()? onPressed;
  final String? tag;
  ProfileModel({
    required this.title,
    required this.subtitle,
    required this.navigationScreen,
    this.onPressed,
    this.tag,
  });
}
