import 'dart:async';

import 'package:flutter/material.dart';
import 'package:money_track/db/transaction/income_and_expense.dart';
import 'package:money_track/screens/onboarding_screens/onboard_screen.dart';
import 'package:money_track/screens/root_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    Timer(const Duration(seconds: 3), (() async {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      bool seen = preferences.getBool('seen') ?? false;
      seen ? goToRootPage() : goToOnboardPage();
    }));

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints.expand(),
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage("assets/images/Splash Screen.png"),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Future<void> goToRootPage() async {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: ((context) => const RootPage()),
      ),
    );
  }

  goToOnboardPage() async {
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: ((ctx) {
      return const OnBoardingScreens();
    })));
  }
}
