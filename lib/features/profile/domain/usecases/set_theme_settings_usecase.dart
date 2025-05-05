import 'package:money_track/core/error/result.dart';
import 'package:money_track/core/use_cases/use_case.dart';
import 'package:money_track/features/profile/domain/repositories/theme_repository.dart';

/// Use case for setting theme settings (theme and mode)
class SetThemeSettingsUseCase implements UseCase<Result<void>, ThemeSettingsParams> {
  final ThemeRepository repository;

  SetThemeSettingsUseCase(this.repository);

  @override
  Future<Result<void>> call({ThemeSettingsParams? params}) {
    if (params == null) {
      throw ArgumentError('Theme settings params cannot be null');
    }
    return repository.setThemeSettings(
      themeName: params.themeName,
      themeMode: params.themeMode,
    );
  }
}

/// Parameters for setting theme settings
class ThemeSettingsParams {
  final String themeName;
  final String themeMode;

  ThemeSettingsParams({
    required this.themeName,
    required this.themeMode,
  });
}
