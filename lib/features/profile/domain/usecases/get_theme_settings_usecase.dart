import 'package:money_track/core/error/result.dart';
import 'package:money_track/core/use_cases/use_case.dart';
import 'package:money_track/features/profile/domain/repositories/theme_repository.dart';

/// Use case for getting theme settings (theme and mode)
class GetThemeSettingsUseCase implements UseCase<Result<Map<String, String>>, void> {
  final ThemeRepository repository;

  GetThemeSettingsUseCase(this.repository);

  @override
  Future<Result<Map<String, String>>> call({void params}) {
    return repository.getThemeSettings();
  }
}
