import 'package:flutter/material.dart';
import 'package:money_track/core/colors.dart';

ThemeData _lightTheme = ThemeData(
  primaryColor: ColorConstants.themeDarkBlue,
  primarySwatch: createMaterialColor(ColorConstants.themeDarkBlue),
  // fontFamily: google,
);

ThemeData _darkTheme = ThemeData(
    primaryColor: ColorConstants.themeDarkBlue,
    primaryColorDark: ColorConstants.themeDarkBlue,
    primarySwatch: createMaterialColor(ColorConstants.themeDarkBlue),
    scaffoldBackgroundColor: const Color(0xFF333333));

bool isDarkMode = false;

ThemeData getThemeData() {
  return isDarkMode ? _darkTheme : _lightTheme;
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
