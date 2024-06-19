import 'package:flutter/material.dart';
import 'package:money_track/presentation/pages/settings/widget/custom_app_bar.dart';

class CurrencyPage extends StatelessWidget {
  const CurrencyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(context, title: "Currency"),
      body: const Center(
          child: Text(
        "Currency",
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
      )),
    );
  }
}
