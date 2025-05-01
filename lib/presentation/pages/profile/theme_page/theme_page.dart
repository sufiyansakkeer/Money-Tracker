import 'package:flutter/material.dart';
import 'package:money_track/presentation/pages/profile/widget/custom_app_bar.dart';

class ThemePage extends StatelessWidget {
  const ThemePage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: customAppBar(context, title: "Theme"),
        body: const Center(
            child: Text(
          "Theme",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        )),
      ),
    );
  }
}
