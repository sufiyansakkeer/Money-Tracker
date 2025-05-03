import 'package:money_track/core/error/result.dart';
import 'package:money_track/core/use_cases/use_case.dart';
import 'package:money_track/domain/entities/category_entity.dart';
import 'package:money_track/domain/repositories/category_repository.dart';

/// Use case for adding a new category
class AddCategoryUseCase implements UseCase<Result<String>, CategoryEntity> {
  final CategoryRepository repository;

  AddCategoryUseCase(this.repository);

  @override
  Future<Result<String>> call({CategoryEntity? params}) {
    if (params == null) {
      throw ArgumentError('CategoryEntity cannot be null');
    }
    return repository.addCategory(params);
  }
}
