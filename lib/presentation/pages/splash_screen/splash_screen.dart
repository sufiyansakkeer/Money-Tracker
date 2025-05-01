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
    super.initState();
    _checkOnboardingStatus();
  }

  Future<void> _checkOnboardingStatus() async {
    await Future.delayed(const Duration(seconds: 2));

    SharedPreferences preferences = await SharedPreferences.getInstance();
    bool seen = preferences.getBool('seen') ?? false;

    if (!mounted) return;

    if (seen) {
      goToRootPage(context);
    } else {
      goToOnboardPage(context);
    }
  }

  @override
  void dispose() {
    super.dispose();
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
