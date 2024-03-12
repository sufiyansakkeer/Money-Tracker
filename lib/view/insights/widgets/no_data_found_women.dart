import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class NoDataFoundWomenWidget extends StatelessWidget {
  const NoDataFoundWomenWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Lottie.asset(
              'assets/images/no-data.json',
              height: 360,
            ),
          ],
        ),
      ),
    );
  }
}
