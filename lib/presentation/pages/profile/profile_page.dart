import 'package:flutter/material.dart';
import 'package:money_track/helper/navigation_extension.dart';
import 'package:money_track/helper/sized_box_extension.dart';
import 'package:money_track/models/profile/profile_title_model.dart';
import 'package:money_track/presentation/pages/profile/about/about_page.dart';
import 'package:money_track/presentation/pages/profile/currency/currency_page.dart';
import 'package:money_track/presentation/pages/profile/theme_page/theme_page.dart';
import 'package:money_track/presentation/pages/profile/widget/reset_drop_down.dart';
import 'package:money_track/repository/profile_repository.dart';

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
              itemBuilder: (context, index) => ProfileTile(
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

List<ProfileModel> _tileList = [
  ProfileModel(
    title: "Analyze",
    subtitle: "",
    navigationScreen: const AnalyzePage(),
    tag: "Analyze",
  ),
  ProfileModel(
    title: "Currency",
    subtitle: "INR",
    navigationScreen: const CurrencyPage(),
    tag: "Currency",
  ),
  ProfileModel(
    title: "Theme",
    subtitle: "Light",
    navigationScreen: const ThemePage(),
    tag: "Theme",
  ),
  ProfileModel(
    title: "Reset",
    subtitle: "",
    navigationScreen: null,
  ),
  ProfileModel(
    title: "",
    subtitle: "",
    navigationScreen: null,
  ),
  ProfileModel(
      title: "About",
      subtitle: "",
      navigationScreen: const AboutPage(),
      tag: "About"),
  ProfileModel(
    title: "Help",
    subtitle: "",
    navigationScreen: null,
    onPressed: () => ProfileRepository().navigateToMail(),
  ),
];
