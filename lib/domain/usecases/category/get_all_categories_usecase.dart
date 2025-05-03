import 'package:money_track/core/error/result.dart';
import 'package:money_track/core/use_cases/use_case.dart';
import 'package:money_track/domain/entities/category_entity.dart';
import 'package:money_track/domain/repositories/category_repository.dart';

/// Use case for getting all categories
class GetAllCategoriesUseCase
    implements UseCase<Result<List<CategoryEntity>>, NoParams> {
  final CategoryRepository repository;

  GetAllCategoriesUseCase(this.repository);

  @override
  Future<Result<List<CategoryEntity>>> call({NoParams? params}) {
    return repository.getAllCategories();
  }
}
