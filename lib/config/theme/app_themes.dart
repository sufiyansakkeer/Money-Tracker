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

  // Theme colors - Light mode (enhanced with more vibrant tones)
  static const Color purpleColor = Color(0xFF7F3DFF);
  static const Color purpleColorLight = Color(0xFFEEE5FF);
  static const Color blueColor = Color(0xFF246BFD);
  static const Color blueColorLight = Color(0xFFE5EFFF);
  static const Color greenColor = Color(0xFF00CA8A);
  static const Color greenColorLight = Color(0xFFE5FFF6);
  static const Color orangeColor = Color(0xFFFF8A00);
  static const Color orangeColorLight = Color(0xFFFFF5E5);
  static const Color redColor = Color(0xFFFD3C4A);
  static const Color redColorLight = Color(0xFFFFE5E8);
  static const Color tealColor = Color(0xFF00C2CB);
  static const Color tealColorLight = Color(0xFFE5F8FA);

  // Theme colors - Dark mode (enhanced for dark backgrounds)
  static const Color purpleColorDark = Color(0xFF9D6FFF);
  static const Color purpleColorDarkLight = Color(0xFF3A2A66);
  static const Color blueColorDark = Color(0xFF4C8DFF);
  static const Color blueColorDarkLight = Color(0xFF1A3366);
  static const Color greenColorDark = Color(0xFF2DCE8F);
  static const Color greenColorDarkLight = Color(0xFF0A3D2A);
  static const Color orangeColorDark = Color(0xFFFF9F40);
  static const Color orangeColorDarkLight = Color(0xFF3D2A0A);
  static const Color redColorDark = Color(0xFFFF6B74);
  static const Color redColorDarkLight = Color(0xFF3D1A1D);
  static const Color tealColorDark = Color(0xFF40D6DE);
  static const Color tealColorDarkLight = Color(0xFF0A3D3F);

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
    Color secondaryColor;

    // Get the corresponding light secondary color
    switch (themeName) {
      case blue:
        secondaryColor = blueColorLight;
        break;
      case green:
        secondaryColor = greenColorLight;
        break;
      case orange:
        secondaryColor = orangeColorLight;
        break;
      case red:
        secondaryColor = redColorLight;
        break;
      case teal:
        secondaryColor = tealColorLight;
        break;
      case purple:
      default:
        secondaryColor = purpleColorLight;
    }

    return ThemeData(
      brightness: Brightness.light,
      useMaterial3: true,
      fontFamily: GoogleFonts.poppins().fontFamily,
      scaffoldBackgroundColor: Colors.white,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: Colors.black87,
          fontFamily: GoogleFonts.poppins().fontFamily,
          fontWeight: FontWeight.w600,
          fontSize: 18,
        ),
        iconTheme: IconThemeData(color: primaryColor),
      ),
      primaryColor: primaryColor,
      colorScheme: ColorScheme.light(
        primary: primaryColor,
        secondary: secondaryColor,
        tertiary: primaryColor.withValues(alpha: 0.7),
        surface: Colors.white,
        error: redColor,
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        color: Colors.white,
        shadowColor: Colors.black.withValues(alpha: 0.1),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith<Color>(
            (Set<WidgetState> states) {
              if (states.contains(WidgetState.disabled)) {
                return primaryColor.withValues(alpha: 0.5);
              }
              return primaryColor;
            },
          ),
          foregroundColor: WidgetStateProperty.all(Colors.white),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          elevation: WidgetStateProperty.resolveWith<double>(
            (Set<WidgetState> states) {
              if (states.contains(WidgetState.pressed)) {
                return 0;
              }
              return 2;
            },
          ),
          overlayColor:
              WidgetStateProperty.all(Colors.white.withValues(alpha: 0.1)),
          padding: WidgetStateProperty.all(
            const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          ),
          animationDuration: const Duration(milliseconds: 200),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: ButtonStyle(
          foregroundColor: WidgetStateProperty.all(primaryColor),
          overlayColor:
              WidgetStateProperty.all(primaryColor.withValues(alpha: 0.1)),
          textStyle: WidgetStateProperty.all(
            TextStyle(
              fontFamily: GoogleFonts.poppins().fontFamily,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.grey[50],
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: primaryColor, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: redColor, width: 1.5),
        ),
        labelStyle: TextStyle(
          color: Colors.grey[700],
          fontFamily: GoogleFonts.poppins().fontFamily,
        ),
        floatingLabelStyle: TextStyle(
          color: primaryColor,
          fontFamily: GoogleFonts.poppins().fontFamily,
          fontWeight: FontWeight.w600,
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        backgroundColor: Colors.white,
        modalBackgroundColor: Colors.white,
        elevation: 8,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: primaryColor,
        unselectedItemColor: Colors.grey[400],
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      dividerTheme: DividerThemeData(
        color: Colors.grey[200],
        thickness: 1,
        space: 1,
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith<Color>(
          (Set<WidgetState> states) {
            if (states.contains(WidgetState.selected)) {
              return primaryColor;
            }
            return Colors.transparent;
          },
        ),
        side: BorderSide(color: Colors.grey[400]!),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
      ),
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith<Color>(
          (Set<WidgetState> states) {
            if (states.contains(WidgetState.selected)) {
              return primaryColor;
            }
            return Colors.grey[400]!;
          },
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith<Color>(
          (Set<WidgetState> states) {
            if (states.contains(WidgetState.selected)) {
              return primaryColor;
            }
            return Colors.grey[400]!;
          },
        ),
        trackColor: WidgetStateProperty.resolveWith<Color>(
          (Set<WidgetState> states) {
            if (states.contains(WidgetState.selected)) {
              return primaryColor.withValues(alpha: 0.5);
            }
            return Colors.grey[300]!;
          },
        ),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: primaryColor,
        circularTrackColor: secondaryColor,
        linearTrackColor: secondaryColor,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: secondaryColor,
        disabledColor: Colors.grey[200],
        selectedColor: primaryColor,
        secondarySelectedColor: primaryColor,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        labelStyle: TextStyle(
          color: Colors.black87,
          fontFamily: GoogleFonts.poppins().fontFamily,
        ),
        secondaryLabelStyle: TextStyle(
          color: Colors.white,
          fontFamily: GoogleFonts.poppins().fontFamily,
        ),
        brightness: Brightness.light,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  // Get dark theme data by name
  static ThemeData getDarkThemeData(String themeName) {
    final primaryColor = getThemeColor(themeName, isDarkMode: true);
    Color secondaryColor;

    // Get the corresponding dark secondary color
    switch (themeName) {
      case blue:
        secondaryColor = blueColorDarkLight;
        break;
      case green:
        secondaryColor = greenColorDarkLight;
        break;
      case orange:
        secondaryColor = orangeColorDarkLight;
        break;
      case red:
        secondaryColor = redColorDarkLight;
        break;
      case teal:
        secondaryColor = tealColorDarkLight;
        break;
      case purple:
      default:
        secondaryColor = purpleColorDarkLight;
    }

    return ThemeData(
      brightness: Brightness.dark,
      useMaterial3: true,
      fontFamily: GoogleFonts.poppins().fontFamily,
      scaffoldBackgroundColor: const Color(0xFF121212),
      appBarTheme: AppBarTheme(
        backgroundColor: const Color(0xFF1E1E1E),
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontFamily: GoogleFonts.poppins().fontFamily,
          fontWeight: FontWeight.w600,
          fontSize: 18,
        ),
        iconTheme: IconThemeData(color: primaryColor),
      ),
      primaryColor: primaryColor,
      colorScheme: ColorScheme.dark(
        primary: primaryColor,
        secondary: secondaryColor,
        tertiary: primaryColor.withValues(alpha: 0.7),
        surface: const Color(0xFF1E1E1E),
        error: redColorDark,
      ),
      cardTheme: CardThemeData(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        color: const Color(0xFF1E1E1E),
        shadowColor: Colors.black.withValues(alpha: 0.3),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith<Color>(
            (Set<WidgetState> states) {
              if (states.contains(WidgetState.disabled)) {
                return primaryColor.withValues(alpha: 0.5);
              }
              return primaryColor;
            },
          ),
          foregroundColor: WidgetStateProperty.all(Colors.white),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          elevation: WidgetStateProperty.resolveWith<double>(
            (Set<WidgetState> states) {
              if (states.contains(WidgetState.pressed)) {
                return 0;
              }
              return 4;
            },
          ),
          overlayColor:
              WidgetStateProperty.all(Colors.white.withValues(alpha: 0.1)),
          padding: WidgetStateProperty.all(
            const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          ),
          animationDuration: const Duration(milliseconds: 200),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: ButtonStyle(
          foregroundColor: WidgetStateProperty.all(primaryColor),
          overlayColor:
              WidgetStateProperty.all(primaryColor.withValues(alpha: 0.2)),
          textStyle: WidgetStateProperty.all(
            TextStyle(
              fontFamily: GoogleFonts.poppins().fontFamily,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF2A2A2A),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: primaryColor, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: redColorDark, width: 1.5),
        ),
        labelStyle: const TextStyle(
          color: Colors.grey,
        ),
        floatingLabelStyle: TextStyle(
          color: primaryColor,
          fontWeight: FontWeight.w600,
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        backgroundColor: Color(0xFF1E1E1E),
        modalBackgroundColor: Color(0xFF1E1E1E),
        elevation: 8,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: const Color(0xFF1E1E1E),
        selectedItemColor: primaryColor,
        unselectedItemColor: Colors.grey[600],
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      dividerTheme: const DividerThemeData(
        color: Color(0xFF3E3E3E),
        thickness: 1,
        space: 1,
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith<Color>(
          (Set<WidgetState> states) {
            if (states.contains(WidgetState.selected)) {
              return primaryColor;
            }
            return Colors.transparent;
          },
        ),
        side: const BorderSide(color: Colors.grey),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
      ),
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith<Color>(
          (Set<WidgetState> states) {
            if (states.contains(WidgetState.selected)) {
              return primaryColor;
            }
            return Colors.grey;
          },
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith<Color>(
          (Set<WidgetState> states) {
            if (states.contains(WidgetState.selected)) {
              return primaryColor;
            }
            return Colors.grey;
          },
        ),
        trackColor: WidgetStateProperty.resolveWith<Color>(
          (Set<WidgetState> states) {
            if (states.contains(WidgetState.selected)) {
              return primaryColor.withValues(alpha: 0.5);
            }
            return Colors.grey[800]!;
          },
        ),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: primaryColor,
        circularTrackColor: secondaryColor,
        linearTrackColor: secondaryColor,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: secondaryColor,
        disabledColor: Colors.grey[800],
        selectedColor: primaryColor,
        secondarySelectedColor: primaryColor,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        labelStyle: TextStyle(
          color: Colors.white,
          fontFamily: GoogleFonts.poppins().fontFamily,
        ),
        secondaryLabelStyle: TextStyle(
          color: Colors.white,
          fontFamily: GoogleFonts.poppins().fontFamily,
        ),
        brightness: Brightness.dark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
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
