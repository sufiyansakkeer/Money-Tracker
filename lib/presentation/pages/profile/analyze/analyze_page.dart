import 'package:flutter/material.dart';
import 'package:money_track/presentation/pages/profile/widget/custom_app_bar.dart';

class AnalyzePage extends StatelessWidget {
  const AnalyzePage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: customAppBar(context, title: "Analyze"),
        body: const Center(child: Text("Body")),
      ),
    );
  }
}
