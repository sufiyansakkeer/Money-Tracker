import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:money_track/helper/sized_box_extension.dart';

class LottieOnBoardWidget extends StatelessWidget {
  const LottieOnBoardWidget({
    super.key,
    required this.lottie,
    required this.lottieTitle,
  });
  final String lottie;
  final String lottieTitle;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 70,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          LottieBuilder.asset(
            lottie,
            height: 350,
          ),
          20.height(),
          Text(
            lottieTitle,
            style: const TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          )
        ],
      ),
    );
  }
}

List<String> lottieList = [
  "assets/images/90698-online-investment.json",
  'assets/images/organize-in-closet-wardrobe-animation.json',
  'assets/images/graph-stats.json',
];

List<String> lottieTitleList = [
  'Save Your Money Conveniently',
  'Arrange Your Money Conveniently',
  'Get Real Time Graph Insights',
];
