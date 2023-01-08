import 'package:flutter/material.dart';
import 'package:money_track/profile/profile_page.dart';
import 'package:money_track/home/home_screen.dart';
import 'package:money_track/screens/root_page.dart';

void main() {
  runApp(
    const MoneyTrack(),
  );
}

MaterialColor createMaterialColor(Color color) {
  List strengths = <double>[.05];
  Map<int, Color> swatch = {};
  final int r = color.red, g = color.green, b = color.blue;

  for (int i = 1; i < 10; i++) {
    strengths.add(0.1 * i);
  }
  for (var strength in strengths) {
    final double ds = 0.5 - strength;
    swatch[(strength * 1000).round()] = Color.fromRGBO(
      r + ((ds < 0 ? r : (255 - r)) * ds).round(),
      g + ((ds < 0 ? g : (255 - g)) * ds).round(),
      b + ((ds < 0 ? b : (255 - b)) * ds).round(),
      1,
    );
  }
  return MaterialColor(color.value, swatch);
}

class MoneyTrack extends StatelessWidget {
  const MoneyTrack({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: createMaterialColor(
          const Color(0xFF2E49FB),
        ),
      ),
      home: const RootPage(),
    );
  }
}
