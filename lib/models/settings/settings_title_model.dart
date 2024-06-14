import 'package:flutter/material.dart';

class SettingsModel {
  final String title;
  final String subtitle;
  final Widget? navigationScreen;
  final void Function()? onPressed;
  final String? tag;
  SettingsModel({
    required this.title,
    required this.subtitle,
    required this.navigationScreen,
    this.onPressed,
    this.tag,
  });
}
