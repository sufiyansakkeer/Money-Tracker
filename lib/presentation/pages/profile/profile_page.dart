import 'package:flutter/material.dart';
import 'package:money_track/helper/navigation_extension.dart';
import 'package:money_track/helper/sized_box_extension.dart';
import 'package:money_track/models/settings/settings_title_model.dart';
import 'package:money_track/presentation/pages/profile/about/about_page.dart';
import 'package:money_track/presentation/pages/profile/currency/currency_page.dart';
import 'package:money_track/presentation/pages/profile/theme_page/theme_page.dart';
import 'package:money_track/presentation/pages/profile/widget/reset_drop_down.dart';
import 'package:money_track/repository/settings_repository.dart';

import 'analyze/analyze_page.dart';
import 'widget/settings_tile.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Column(
          children: [
            20.height(),
            const Text(
              "Profile",
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
                  } else if (_tileList[index].onPressed != null) {
                    _tileList[index].onPressed;
                  }
                  if (_tileList[index].title == "Reset") {
                    showModalBottomSheet(
                      context: context,
                      builder: (context) => const ResetDropDown(),
                    );
                  }
                },
              ),
              itemCount: _tileList.length,
            )
          ],
        ),
      ),
    );
  }
}

List<SettingsModel> _tileList = [
  SettingsModel(
    title: "Analyze",
    subtitle: "",
    navigationScreen: const AnalyzePage(),
    tag: "Analyze",
  ),
  SettingsModel(
    title: "Currency",
    subtitle: "INR",
    navigationScreen: const CurrencyPage(),
    tag: "Currency",
  ),
  SettingsModel(
    title: "Theme",
    subtitle: "Light",
    navigationScreen: const ThemePage(),
    tag: "Theme",
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
      navigationScreen: const AboutPage(),
      tag: "About"),
  SettingsModel(
    title: "Help",
    subtitle: "",
    navigationScreen: null,
    onPressed: () => SettingsRepository().navigateToMail(),
  ),
];
