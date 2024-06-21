import 'package:flutter/material.dart';
import 'package:money_track/config/theme/theme.dart';

class ColorConstants {
  static Color themeColor =
      isDarkMode ? const Color(0xFF7F3DFF) : const Color(0xFF7F3DFF);
  static Color expenseColor =
      isDarkMode ? const Color(0xFFFD3C4A) : const Color(0xFFFD3C4A);
  static Color incomeColor =
      isDarkMode ? const Color(0xFF00A86B) : const Color(0xFF00A86B);
  static Color secondaryColor =
      isDarkMode ? const Color(0xFFEEE5FF) : const Color(0xFFEEE5FF);
  static Color bottomNaColor = isDarkMode ? Colors.white : Colors.white;
  static Color borderColor =
      isDarkMode ? const Color(0xFFDDDCDC) : const Color(0xFFDDDCDC);
}
