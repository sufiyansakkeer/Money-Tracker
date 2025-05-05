import 'package:money_track/core/error/result.dart';

abstract class ThemeRepository {
  /// Get the currently selected theme
  Future<Result<String>> getSelectedTheme();

  /// Set the selected theme
  Future<Result<void>> setSelectedTheme(String themeName);

  /// Get the currently selected theme mode
  Future<Result<String>> getSelectedThemeMode();

  /// Set the selected theme mode
  Future<Result<void>> setSelectedThemeMode(String themeMode);

  /// Get both theme and theme mode
  Future<Result<Map<String, String>>> getThemeSettings();

  /// Set both theme and theme mode
  Future<Result<void>> setThemeSettings(
      {required String themeName, required String themeMode});
}
