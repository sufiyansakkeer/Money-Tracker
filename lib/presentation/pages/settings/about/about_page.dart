import 'package:flutter/material.dart';
import 'package:money_track/presentation/pages/settings/widget/custom_app_bar.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(context, title: "About"),
      body: const Center(
          child: Text(
        "About",
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
      )),
    );
  }
}
