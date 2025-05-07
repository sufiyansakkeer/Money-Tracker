import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:money_track/core/error/failures.dart';
import 'package:money_track/core/error/result.dart';
import 'package:money_track/core/use_cases/use_case.dart';
import 'package:money_track/domain/entities/category_entity.dart';
import 'package:money_track/domain/repositories/category_repository.dart';
import 'package:money_track/domain/usecases/category/get_all_categories_usecase.dart';

// Mock class for CategoryRepository
class MockCategoryRepository extends Mock implements CategoryRepository {}

void main() {
  late GetAllCategoriesUseCase useCase;
  late MockCategoryRepository mockCategoryRepository;

  setUp(() {
    mockCategoryRepository = MockCategoryRepository();
    useCase = GetAllCategoriesUseCase(mockCategoryRepository);
  });

  final tCategories = [
    CategoryEntity(
      id: '1',
      categoryName: 'Food',
      type: TransactionType.expense,
      categoryType: CategoryType.food,
    ),
    CategoryEntity(
      id: '2',
      categoryName: 'Salary',
      type: TransactionType.income,
      categoryType: CategoryType.salary,
    ),
  ];

  test('should get all categories from the repository', () async {
    // arrange
    when(mockCategoryRepository.getAllCategories())
        .thenAnswer((_) async => Success(tCategories));

    // act
    final result = await useCase(params: NoParams());

    // assert
    expect(result, Success(tCategories));
    verify(mockCategoryRepository.getAllCategories());
    verifyNoMoreInteractions(mockCategoryRepository);
  });

  test('should pass through errors from the repository', () async {
    // arrange
    final failure =
        Error<List<CategoryEntity>>(DatabaseFailure(message: 'Test error'));
    when(mockCategoryRepository.getAllCategories())
        .thenAnswer((_) async => failure);

    // act
    final result = await useCase(params: NoParams());

    // assert
    expect(result, failure);
    verify(mockCategoryRepository.getAllCategories());
    verifyNoMoreInteractions(mockCategoryRepository);
  });
}
