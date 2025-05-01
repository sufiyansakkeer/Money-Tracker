import 'package:flutter/material.dart';
import 'package:money_track/core/constants/colors.dart';

ThemeData _lightTheme = ThemeData(
  primaryColor: ColorConstants.themeColor,
  // primarySwatch: createMaterialColor(ColorConstants.themeColor),
  // fontFamily: google,
);

ThemeData _darkTheme = ThemeData(
    primaryColor: ColorConstants.themeColor,
    primaryColorDark: ColorConstants.themeColor,
    // primarySwatch: MaterialColor(, swatch),
    scaffoldBackgroundColor: const Color(0xFF333333));

bool isDarkMode = false;

ThemeData getThemeData(BuildContext context) {
  return MediaQuery.platformBrightnessOf(context) == Brightness.dark
      ? _darkTheme
      : _lightTheme;
}
