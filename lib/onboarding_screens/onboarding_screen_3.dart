import 'package:flutter/material.dart';

class OnBoardingScreenThree extends StatelessWidget {
  const OnBoardingScreenThree({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints.expand(),
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage("assets/images/iPhone 8 - 2@2x.png"),
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
