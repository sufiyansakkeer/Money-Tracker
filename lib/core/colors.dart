import 'package:flutter/material.dart';
import 'package:money_track/core/theme.dart';

class ColorConstants {
  static Color themeDarkBlue =
      isDarkMode ? const Color(0xFF1A2D7A) : const Color(0xFF2E49FB);
  static Color expenseColor =
      isDarkMode ? const Color(0xFF6F22A1) : const Color(0xFFDE45FE);
  static Color incomeColor =
      isDarkMode ? const Color(0xFF345A73) : const Color(0xFF68AFF6);
  static Color secondaryThemeBlue =
      isDarkMode ? const Color(0xD42E49FB) : const Color(0x412E49FB);
}
