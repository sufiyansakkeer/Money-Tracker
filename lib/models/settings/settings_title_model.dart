import 'package:flutter/material.dart';

class SettingsModel {
  final String title;
  final String subtitle;
  final Widget? navigationScreen;

  SettingsModel({
    required this.title,
    required this.subtitle,
    required this.navigationScreen,
  });
}
