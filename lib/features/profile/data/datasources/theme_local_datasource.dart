import 'dart:developer';

import 'package:money_track/config/theme/app_themes.dart';
import 'package:money_track/core/error/failures.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class ThemeLocalDataSource {
  /// Get the currently selected theme
  Future<String> getSelectedTheme();

  /// Set the selected theme
  Future<void> setSelectedTheme(String themeName);

  /// Get the currently selected theme mode
  Future<String> getSelectedThemeMode();

  /// Set the selected theme mode
  Future<void> setSelectedThemeMode(String themeMode);

  /// Get both theme and theme mode
  Future<Map<String, String>> getThemeSettings();

  /// Set both theme and theme mode
  Future<void> setThemeSettings(
      {required String themeName, required String themeMode});
}

class ThemeLocalDataSourceImpl implements ThemeLocalDataSource {
  static const String _themeKey = 'selected_theme';
  static const String _themeModeKey = 'selected_theme_mode';

  @override
  Future<String> getSelectedTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final selectedTheme =
          prefs.getString(_themeKey) ?? AppThemes.defaultTheme;
      return selectedTheme;
    } catch (e) {
      log(e.toString(), name: "Get selected theme exception");
      throw DatabaseFailure(
          message: "Failed to get selected theme: ${e.toString()}");
    }
  }

  @override
  Future<void> setSelectedTheme(String themeName) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_themeKey, themeName);
    } catch (e) {
      log(e.toString(), name: "Set selected theme exception");
      throw DatabaseFailure(
          message: "Failed to set selected theme: ${e.toString()}");
    }
  }

  @override
  Future<String> getSelectedThemeMode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final selectedThemeMode =
          prefs.getString(_themeModeKey) ?? AppThemes.defaultMode;
      return selectedThemeMode;
    } catch (e) {
      log(e.toString(), name: "Get selected theme mode exception");
      throw DatabaseFailure(
          message: "Failed to get selected theme mode: ${e.toString()}");
    }
  }

  @override
  Future<void> setSelectedThemeMode(String themeMode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_themeModeKey, themeMode);
    } catch (e) {
      log(e.toString(), name: "Set selected theme mode exception");
      throw DatabaseFailure(
          message: "Failed to set selected theme mode: ${e.toString()}");
    }
  }

  @override
  Future<Map<String, String>> getThemeSettings() async {
    try {
      final theme = await getSelectedTheme();
      final mode = await getSelectedThemeMode();
      return {
        'theme': theme,
        'mode': mode,
      };
    } catch (e) {
      log(e.toString(), name: "Get theme settings exception");
      throw DatabaseFailure(
          message: "Failed to get theme settings: ${e.toString()}");
    }
  }

  @override
  Future<void> setThemeSettings(
      {required String themeName, required String themeMode}) async {
    try {
      await setSelectedTheme(themeName);
      await setSelectedThemeMode(themeMode);
    } catch (e) {
      log(e.toString(), name: "Set theme settings exception");
      throw DatabaseFailure(
          message: "Failed to set theme settings: ${e.toString()}");
    }
  }
}
