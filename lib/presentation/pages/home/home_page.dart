import 'package:flutter/material.dart';
import 'package:money_track/core/constants/colors.dart';
import 'dart:math' as math;

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFFFF6E5),
              Colors.white,
            ],
          ),
        ),
        child: const Column(
          children: [
            Text(
              "Account Balance",
            ),
          ],
        ),
      ),
    );
  }
}
