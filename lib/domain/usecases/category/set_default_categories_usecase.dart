import 'package:money_track/core/error/result.dart';
import 'package:money_track/core/use_cases/use_case.dart';
import 'package:money_track/domain/repositories/category_repository.dart';

/// Use case for setting default categories
class SetDefaultCategoriesUseCase implements UseCase<Result<void>, NoParams> {
  final CategoryRepository repository;

  SetDefaultCategoriesUseCase(this.repository);

  @override
  Future<Result<void>> call({NoParams? params}) {
    return repository.setDefaultCategories();
  }
}
