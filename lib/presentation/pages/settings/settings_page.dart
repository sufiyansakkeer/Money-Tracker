import 'package:flutter/material.dart';
import 'package:money_track/helper/navigation_extension.dart';
import 'package:money_track/helper/sized_box_extension.dart';
import 'package:money_track/models/settings/settings_title_model.dart';

import 'widget/settings_tile.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
          ),
          child: Column(
            children: [
              20.height(),
              const Text(
                "Settings",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              30.height(),
              ListView.separated(
                separatorBuilder: (context, index) => 20.height(),
                primary: false,
                shrinkWrap: true,
                itemBuilder: (context, index) => SettingsTile(
                  title: _tileList[index].title,
                  subtitle: _tileList[index].subtitle,
                  onPressed: () {
                    if (_tileList[index].navigationScreen != null) {
                      context.pushWithRightToLeftTransition(
                          _tileList[index].navigationScreen!);
                    }
                  },
                ),
                itemCount: _tileList.length,
              )
            ],
          ),
        ),
      ),
    );
  }
}

List<SettingsModel> _tileList = [
  SettingsModel(
    title: "Analyze",
    subtitle: "",
    navigationScreen: null,
  ),
  SettingsModel(
    title: "Currency",
    subtitle: "INR",
    navigationScreen: null,
  ),
  SettingsModel(
    title: "Theme",
    subtitle: "White",
    navigationScreen: null,
  ),
  SettingsModel(
    title: "Reset",
    subtitle: "",
    navigationScreen: null,
  ),
  SettingsModel(
    title: "",
    subtitle: "",
    navigationScreen: null,
  ),
  SettingsModel(
    title: "About",
    subtitle: "",
    navigationScreen: null,
  ),
  SettingsModel(
    title: "Help",
    subtitle: "",
    navigationScreen: null,
  ),
];
