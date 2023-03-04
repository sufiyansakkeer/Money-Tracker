import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class OnBoardingTwo extends StatelessWidget {
  const OnBoardingTwo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding:
            const EdgeInsets.only(top: 70, bottom: 70, left: 20, right: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 250,
              child: Lottie.asset(
                'assets/images/organize-in-closet-wardrobe-animation.json',
                // fit: BoxFit.fill,
              ),
            ),
            const Text(
              'Arrange Your Money\n Conveniently',
              style: TextStyle(
                fontSize: 30,
              ),
            )
          ],
        ),
      ),
    );
  }
}
