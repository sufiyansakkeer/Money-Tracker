import 'package:money_track/core/error/failures.dart';
import 'package:money_track/core/error/result.dart';
import 'package:money_track/features/profile/data/datasources/theme_local_datasource.dart';
import 'package:money_track/features/profile/domain/repositories/theme_repository.dart';

class ThemeRepositoryImpl implements ThemeRepository {
  final ThemeLocalDataSource localDataSource;

  ThemeRepositoryImpl({required this.localDataSource});

  @override
  Future<Result<String>> getSelectedTheme() async {
    try {
      final themeName = await localDataSource.getSelectedTheme();
      return Success(themeName);
    } catch (e) {
      return Error(DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<void>> setSelectedTheme(String themeName) async {
    try {
      await localDataSource.setSelectedTheme(themeName);
      return const Success(null);
    } catch (e) {
      return Error(DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<String>> getSelectedThemeMode() async {
    try {
      final themeMode = await localDataSource.getSelectedThemeMode();
      return Success(themeMode);
    } catch (e) {
      return Error(DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<void>> setSelectedThemeMode(String themeMode) async {
    try {
      await localDataSource.setSelectedThemeMode(themeMode);
      return const Success(null);
    } catch (e) {
      return Error(DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<Map<String, String>>> getThemeSettings() async {
    try {
      final settings = await localDataSource.getThemeSettings();
      return Success(settings);
    } catch (e) {
      return Error(DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<void>> setThemeSettings(
      {required String themeName, required String themeMode}) async {
    try {
      await localDataSource.setThemeSettings(
          themeName: themeName, themeMode: themeMode);
      return const Success(null);
    } catch (e) {
      return Error(DatabaseFailure(message: e.toString()));
    }
  }
}
