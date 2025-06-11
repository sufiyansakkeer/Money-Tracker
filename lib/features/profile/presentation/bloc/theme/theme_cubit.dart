import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:money_track/config/theme/app_themes.dart';
import 'package:money_track/features/profile/domain/usecases/get_selected_theme_mode_usecase.dart';
import 'package:money_track/features/profile/domain/usecases/get_selected_theme_usecase.dart';
import 'package:money_track/features/profile/domain/usecases/get_theme_settings_usecase.dart';
import 'package:money_track/features/profile/domain/usecases/set_selected_theme_mode_usecase.dart';
import 'package:money_track/features/profile/domain/usecases/set_selected_theme_usecase.dart';
import 'package:money_track/features/profile/domain/usecases/set_theme_settings_usecase.dart';
import 'package:money_track/features/profile/presentation/bloc/theme/theme_state.dart';

class ThemeCubit extends Cubit<ThemeState> {
  final GetSelectedThemeUseCase getSelectedThemeUseCase;
  final SetSelectedThemeUseCase setSelectedThemeUseCase;
  final GetSelectedThemeModeUseCase getSelectedThemeModeUseCase;
  final SetSelectedThemeModeUseCase setSelectedThemeModeUseCase;
  final GetThemeSettingsUseCase getThemeSettingsUseCase;
  final SetThemeSettingsUseCase setThemeSettingsUseCase;

  ThemeCubit({
    required this.getSelectedThemeUseCase,
    required this.setSelectedThemeUseCase,
    required this.getSelectedThemeModeUseCase,
    required this.setSelectedThemeModeUseCase,
    required this.getThemeSettingsUseCase,
    required this.setThemeSettingsUseCase,
  }) : super(ThemeInitial());

  /// Load the selected theme and theme mode
  Future<void> loadTheme() async {
    emit(ThemeLoading());

    try {
      final result = await getThemeSettingsUseCase();

      result.fold(
        (success) {
          final themeName = success['theme'] ?? AppThemes.defaultTheme;
          final themeMode = success['mode'] ?? AppThemes.defaultMode;

          final lightThemeData = AppThemes.getLightThemeData(themeName);
          final darkThemeData = AppThemes.getDarkThemeData(themeName);
          final appThemeMode = AppThemes.stringToThemeMode(themeMode);

          final primaryColor = AppThemes.getThemeColor(themeName);
          final darkPrimaryColor =
              AppThemes.getThemeColor(themeName, isDarkMode: true);

          emit(ThemeLoaded(
            themeName: themeName,
            themeMode: themeMode,
            lightThemeData: lightThemeData,
            darkThemeData: darkThemeData,
            appThemeMode: appThemeMode,
            primaryColor: primaryColor,
            darkPrimaryColor: darkPrimaryColor,
          ));
        },
        (error) {
          emit(ThemeError(message: error.message));
        },
      );
    } catch (e) {
      emit(ThemeError(message: e.toString()));
    }
  }

  /// Set the selected theme
  Future<void> setTheme(String themeName) async {
    emit(ThemeLoading());

    try {
      // Get current theme mode
      final modeResult = await getSelectedThemeModeUseCase();

      String currentMode = AppThemes.defaultMode;
      modeResult.fold(
        (success) => currentMode = success,
        (error) {},
      );

      // Set theme settings with new theme name and current mode
      final params = ThemeSettingsParams(
        themeName: themeName,
        themeMode: currentMode,
      );

      final result = await setThemeSettingsUseCase(params: params);

      result.fold(
        (success) async {
          // Reload theme to reflect the change
          await loadTheme();
        },
        (error) {
          emit(ThemeError(message: error.message));
        },
      );
    } catch (e) {
      emit(ThemeError(message: e.toString()));
    }
  }

  /// Set the selected theme mode
  Future<void> setThemeMode(String themeMode) async {
    emit(ThemeLoading());

    try {
      // Get current theme
      final themeResult = await getSelectedThemeUseCase();

      String currentTheme = AppThemes.defaultTheme;
      themeResult.fold(
        (success) => currentTheme = success,
        (error) {},
      );

      // Set theme settings with current theme and new mode
      final params = ThemeSettingsParams(
        themeName: currentTheme,
        themeMode: themeMode,
      );

      final result = await setThemeSettingsUseCase(params: params);

      result.fold(
        (success) async {
          // Reload theme to reflect the change
          await loadTheme();
        },
        (error) {
          emit(ThemeError(message: error.message));
        },
      );
    } catch (e) {
      emit(ThemeError(message: e.toString()));
    }
  }

  /// Set both theme and theme mode
  Future<void> setThemeSettings(String themeName, String themeMode) async {
    emit(ThemeLoading());

    try {
      final params = ThemeSettingsParams(
        themeName: themeName,
        themeMode: themeMode,
      );

      final result = await setThemeSettingsUseCase(params: params);

      result.fold(
        (success) async {
          // Reload theme to reflect the change
          await loadTheme();
        },
        (error) {
          emit(ThemeError(message: error.message));
        },
      );
    } catch (e) {
      emit(ThemeError(message: e.toString()));
    }
  }
}
