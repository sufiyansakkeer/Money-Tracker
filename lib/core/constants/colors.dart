import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:money_track/features/profile/presentation/bloc/theme/theme_cubit.dart';
import 'package:money_track/features/profile/presentation/bloc/theme/theme_state.dart';

class ColorConstants {
  // Default colors - Light mode
  static const Color _defaultThemeColor = Color(0xFF7F3DFF);
  static const Color _defaultExpenseColor = Color(0xFFFD3C4A);
  static const Color _defaultIncomeColor = Color(0xFF00A86B);
  static const Color _defaultSecondaryColor = Color(0xFFEEE5FF);
  static const Color _defaultBorderColor = Color(0xFFDDDCDC);

  // Default colors - Dark mode
  static const Color _defaultThemeColorDark = Color(0xFF9D6FFF);
  static const Color _defaultExpenseColorDark = Color(0xFFFF6B74);
  static const Color _defaultIncomeColorDark = Color(0xFF2DCE8F);
  static const Color _defaultSecondaryColorDark = Color(0xFF6E5BA3);
  static const Color _defaultBorderColorDark = Color(0xFF3E3E3E);

  // Get primary theme color from context
  static Color getThemeColor(BuildContext context) {
    final state = context.watch<ThemeCubit>().state;
    if (state is ThemeLoaded) {
      final isDark = _isDarkMode(context);
      return isDark ? state.darkPrimaryColor : state.primaryColor;
    }
    return _isDarkMode(context) ? _defaultThemeColorDark : _defaultThemeColor;
  }

  // Get expense color from context
  static Color getExpenseColor(BuildContext context) {
    return _isDarkMode(context)
        ? _defaultExpenseColorDark
        : _defaultExpenseColor;
  }

  // Get income color from context
  static Color getIncomeColor(BuildContext context) {
    return _isDarkMode(context) ? _defaultIncomeColorDark : _defaultIncomeColor;
  }

  // Get secondary color from context
  static Color getSecondaryColor(BuildContext context) {
    final state = context.watch<ThemeCubit>().state;
    if (state is ThemeLoaded) {
      final isDark = _isDarkMode(context);
      final primaryColor = isDark ? state.darkPrimaryColor : state.primaryColor;
      return primaryColor.withValues(alpha: 0.2);
    }
    return _isDarkMode(context)
        ? _defaultSecondaryColorDark
        : _defaultSecondaryColor;
  }

  // Get border color from context
  static Color getBorderColor(BuildContext context) {
    return _isDarkMode(context) ? _defaultBorderColorDark : _defaultBorderColor;
  }

  // Get bottom navigation color from context
  static Color getBottomNavColor(BuildContext context) {
    return _isDarkMode(context) ? const Color(0xFF1E1E1E) : Colors.white;
  }

  // Get text color from context
  static Color getTextColor(BuildContext context) {
    return _isDarkMode(context) ? Colors.white : Colors.black;
  }

  // Get background color from context
  static Color getBackgroundColor(BuildContext context) {
    return _isDarkMode(context) ? const Color(0xFF121212) : Colors.white;
  }

  // Get card color from context
  static Color getCardColor(BuildContext context) {
    return _isDarkMode(context) ? const Color(0xFF1E1E1E) : Colors.white;
  }

  // Check if dark mode is active
  static bool _isDarkMode(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.dark;
  }

  // Static getters for backward compatibility
  static Color get themeColor => _defaultThemeColor;
  static Color get expenseColor => _defaultExpenseColor;
  static Color get incomeColor => _defaultIncomeColor;
  static Color get secondaryColor => _defaultSecondaryColor;
  static Color get bottomNaColor => Colors.white;
  static Color get borderColor => _defaultBorderColor;
}
