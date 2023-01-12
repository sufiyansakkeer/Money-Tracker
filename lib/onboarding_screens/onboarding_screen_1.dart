import 'package:flutter/material.dart';

class OnBoardingOne extends StatelessWidget {
  const OnBoardingOne({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints.expand(),
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage("assets/images/onBoarding 1.png"),
          fit: BoxFit.cover,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: const Color(0x00000000),
          leading: IconButton(
            onPressed: (() {}),
            icon: const Icon(
              Icons.arrow_back_ios_new,
            ),
          ),
        ),
        body: SafeArea(
          child: Column(),
        ),
      ),
    );
  }
}
