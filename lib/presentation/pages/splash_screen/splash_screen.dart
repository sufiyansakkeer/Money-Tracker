import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:money_track/presentation/pages/bottom_navigation/bottom_navigation.dart';
import 'package:money_track/presentation/pages/onboarding_screens/onboard_screen.dart';

import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    Timer(const Duration(seconds: 2), (() async {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      bool seen = preferences.getBool('seen') ?? false;
      if (context.mounted) {
        seen ? goToRootPage(context) : goToOnboardPage(context);
      }
    }));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
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
        builder: ((context) => const BottomNavigationPage()),
      ),
    );
  }

  goToOnboardPage(context) async {
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: ((ctx) {
      return const OnBoardingScreens();
    })));
  }
}
