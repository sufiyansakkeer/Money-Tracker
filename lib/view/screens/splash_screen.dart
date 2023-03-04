import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:money_track/view/screens/onboarding_screens/onboard_screen.dart';
import 'package:money_track/view/screens/root_page.dart';

import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Timer(const Duration(seconds: 2), (() async {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      bool seen = preferences.getBool('seen') ?? false;
      seen ? goToRootPage(context) : goToOnboardPage(context);
    }));
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Center(
          child: Container(
            child: Lottie.asset('assets/images/progression1.json'),
          ),
        ),
      ),
    );
  }

  Future<void> goToRootPage(context) async {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: ((context) => const RootPage()),
      ),
    );
  }

  goToOnboardPage(context) async {
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: ((ctx) {
      return OnBoardingScreens();
    })));
  }
}
