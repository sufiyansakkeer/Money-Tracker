import 'package:money_track/core/error/result.dart';
import 'package:money_track/core/use_cases/use_case.dart';
import 'package:money_track/features/profile/domain/repositories/theme_repository.dart';

/// Use case for getting the selected theme mode
class GetSelectedThemeModeUseCase implements UseCase<Result<String>, void> {
  final ThemeRepository repository;

  GetSelectedThemeModeUseCase(this.repository);

  @override
  Future<Result<String>> call({void params}) {
    return repository.getSelectedThemeMode();
  }
}
