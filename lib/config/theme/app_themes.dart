import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Class that defines all available themes in the app
class AppThemes {
  // Theme names
  static const String purple = 'Purple';
  static const String blue = 'Blue';
  static const String green = 'Green';
  static const String orange = 'Orange';
  static const String red = 'Red';
  static const String teal = 'Teal';

  // Theme modes
  static const String light = 'Light';
  static const String dark = 'Dark';
  static const String system = 'System';

  // Default theme
  static const String defaultTheme = purple;
  static const String defaultMode = light;

  // Theme colors - Light mode
  static const Color purpleColor = Color(0xFF7F3DFF);
  static const Color blueColor = Color(0xFF2196F3);
  static const Color greenColor = Color(0xFF4CAF50);
  static const Color orangeColor = Color(0xFFFF9800);
  static const Color redColor = Color(0xFFE91E63);
  static const Color tealColor = Color(0xFF009688);

  // Theme colors - Dark mode (slightly adjusted for dark backgrounds)
  static const Color purpleColorDark = Color(0xFF9D6FFF);
  static const Color blueColorDark = Color(0xFF64B5F6);
  static const Color greenColorDark = Color(0xFF81C784);
  static const Color orangeColorDark = Color(0xFFFFB74D);
  static const Color redColorDark = Color(0xFFF48FB1);
  static const Color tealColorDark = Color(0xFF4DB6AC);

  // Get all available themes
  static List<ThemeOption> getAllThemes() {
    return [
      ThemeOption(
        name: purple,
        color: purpleColor,
        darkColor: purpleColorDark,
        description: 'Default purple theme',
      ),
      ThemeOption(
        name: blue,
        color: blueColor,
        darkColor: blueColorDark,
        description: 'Calm blue theme',
      ),
      ThemeOption(
        name: green,
        color: greenColor,
        darkColor: greenColorDark,
        description: 'Fresh green theme',
      ),
      ThemeOption(
        name: orange,
        color: orangeColor,
        darkColor: orangeColorDark,
        description: 'Warm orange theme',
      ),
      ThemeOption(
        name: red,
        color: redColor,
        darkColor: redColorDark,
        description: 'Bold red theme',
      ),
      ThemeOption(
        name: teal,
        color: tealColor,
        darkColor: tealColorDark,
        description: 'Soothing teal theme',
      ),
    ];
  }

  // Get theme modes
  static List<ThemeModeOption> getThemeModes() {
    return [
      ThemeModeOption(
        name: light,
        icon: Icons.light_mode,
        themeMode: ThemeMode.light,
        description: 'Light theme mode',
      ),
      ThemeModeOption(
        name: dark,
        icon: Icons.dark_mode,
        themeMode: ThemeMode.dark,
        description: 'Dark theme mode',
      ),
      ThemeModeOption(
        name: system,
        icon: Icons.brightness_auto,
        themeMode: ThemeMode.system,
        description: 'Follow system settings',
      ),
    ];
  }

  // Get theme color by name
  static Color getThemeColor(String themeName, {bool isDarkMode = false}) {
    if (isDarkMode) {
      switch (themeName) {
        case blue:
          return blueColorDark;
        case green:
          return greenColorDark;
        case orange:
          return orangeColorDark;
        case red:
          return redColorDark;
        case teal:
          return tealColorDark;
        case purple:
        default:
          return purpleColorDark;
      }
    } else {
      switch (themeName) {
        case blue:
          return blueColor;
        case green:
          return greenColor;
        case orange:
          return orangeColor;
        case red:
          return redColor;
        case teal:
          return tealColor;
        case purple:
        default:
          return purpleColor;
      }
    }
  }

  // Convert string to ThemeMode
  static ThemeMode stringToThemeMode(String mode) {
    switch (mode) {
      case dark:
        return ThemeMode.dark;
      case system:
        return ThemeMode.system;
      case light:
      default:
        return ThemeMode.light;
    }
  }

  // Get light theme data by name
  static ThemeData getLightThemeData(String themeName) {
    final primaryColor = getThemeColor(themeName);

    return ThemeData(
      brightness: Brightness.light,
      useMaterial3: true,
      fontFamily: GoogleFonts.oxygen().fontFamily,
      scaffoldBackgroundColor: Colors.white,
      appBarTheme: const AppBarTheme(backgroundColor: Colors.white),
      primaryColor: primaryColor,
      colorScheme: ColorScheme.light(
        primary: primaryColor,
        secondary: primaryColor.withValues(alpha: 0.2),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFE0E0E1)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFE0E0E1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: primaryColor),
        ),
      ),
    );
  }

  // Get dark theme data by name
  static ThemeData getDarkThemeData(String themeName) {
    final primaryColor = getThemeColor(themeName, isDarkMode: true);

    return ThemeData(
      brightness: Brightness.dark,
      useMaterial3: true,
      fontFamily: GoogleFonts.oxygen().fontFamily,
      scaffoldBackgroundColor: const Color(0xFF121212),
      appBarTheme: const AppBarTheme(backgroundColor: Color(0xFF1E1E1E)),
      primaryColor: primaryColor,
      colorScheme: ColorScheme.dark(
        primary: primaryColor,
        secondary: primaryColor.withValues(alpha: 0.2),
        surface: const Color(0xFF1E1E1E),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF3E3E3E)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF3E3E3E)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: primaryColor),
        ),
      ),
      cardColor: const Color(0xFF1E1E1E),
      dividerColor: const Color(0xFF3E3E3E),
    );
  }

  // Get theme data by name and mode
  static ThemeData getThemeData(String themeName, {String themeMode = light}) {
    if (themeMode == dark) {
      return getDarkThemeData(themeName);
    } else {
      return getLightThemeData(themeName);
    }
  }
}

/// Class representing a theme option
class ThemeOption {
  final String name;
  final Color color;
  final Color darkColor;
  final String description;

  const ThemeOption({
    required this.name,
    required this.color,
    required this.darkColor,
    required this.description,
  });
}

/// Class representing a theme mode option
class ThemeModeOption {
  final String name;
  final IconData icon;
  final ThemeMode themeMode;
  final String description;

  const ThemeModeOption({
    required this.name,
    required this.icon,
    required this.themeMode,
    required this.description,
  });
}
