import 'package:flutter/material.dart';
import 'package:money_track/screens/root_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    goToHome();
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

  Future<void> goToHome() async {
    await Future.delayed(const Duration(seconds: 3));

    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: ((ctx) {
      return const RootPage();
    })));
  }
}
