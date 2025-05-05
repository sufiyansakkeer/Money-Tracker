import 'package:money_track/core/error/result.dart';
import 'package:money_track/core/use_cases/use_case.dart';
import 'package:money_track/features/profile/domain/repositories/theme_repository.dart';

/// Use case for setting the selected theme
class SetSelectedThemeUseCase implements UseCase<Result<void>, String> {
  final ThemeRepository repository;

  SetSelectedThemeUseCase(this.repository);

  @override
  Future<Result<void>> call({String? params}) {
    if (params == null) {
      throw ArgumentError('Theme name cannot be null');
    }
    return repository.setSelectedTheme(params);
  }
}
