import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:money_track/core/error/failures.dart';
import 'package:money_track/core/error/result.dart';
import 'package:money_track/core/use_cases/use_case.dart';
import 'package:money_track/domain/entities/category_entity.dart';
import 'package:money_track/domain/usecases/category/add_category_usecase.dart';
import 'package:money_track/domain/usecases/category/get_all_categories_usecase.dart';
import 'package:money_track/domain/usecases/category/set_default_categories_usecase.dart';
import 'package:money_track/features/categories/presentation/bloc/category_bloc.dart';

// Mock classes for use cases
class MockGetAllCategoriesUseCase extends Mock
    implements GetAllCategoriesUseCase {}

class MockAddCategoryUseCase extends Mock implements AddCategoryUseCase {}

class MockSetDefaultCategoriesUseCase extends Mock
    implements SetDefaultCategoriesUseCase {}

void main() {
  late CategoryBloc bloc;
  late MockGetAllCategoriesUseCase mockGetAllCategoriesUseCase;
  late MockAddCategoryUseCase mockAddCategoryUseCase;
  late MockSetDefaultCategoriesUseCase mockSetDefaultCategoriesUseCase;

  setUp(() {
    mockGetAllCategoriesUseCase = MockGetAllCategoriesUseCase();
    mockAddCategoryUseCase = MockAddCategoryUseCase();
    mockSetDefaultCategoriesUseCase = MockSetDefaultCategoriesUseCase();

    bloc = CategoryBloc(
      getAllCategoriesUseCase: mockGetAllCategoriesUseCase,
      addCategoryUseCase: mockAddCategoryUseCase,
      setDefaultCategoriesUseCase: mockSetDefaultCategoriesUseCase,
    );
  });

  test('initial state should be CategoryInitial', () {
    // assert
    expect(bloc.state, isA<CategoryInitial>());
  });

  group('GetAllCategoriesEvent', () {
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

    test(
        'should emit [CategoryLoading, CategoryLoaded] when data is gotten successfully',
        () async {
      // arrange
      when(mockGetAllCategoriesUseCase(params: any))
          .thenAnswer((_) async => Success(tCategories));

      // assert later
      final expected = [
        CategoryLoading(),
        CategoryLoaded(categoryList: tCategories),
      ];
      expectLater(bloc.stream, emitsInOrder(expected));

      // act
      bloc.add(GetAllCategoriesEvent());
    });

    test('should emit [CategoryLoading, CategoryError] when getting data fails',
        () async {
      // arrange
      when(mockGetAllCategoriesUseCase(params: any)).thenAnswer(
          (_) async => Error(DatabaseFailure(message: 'Test error')));

      // assert later
      final expected = [
        CategoryLoading(),
        CategoryError(message: 'Exception: Test error'),
      ];
      expectLater(bloc.stream, emitsInOrder(expected));

      // act
      bloc.add(GetAllCategoriesEvent());
    });
  });

  group('AddCategoryEvent', () {
    test(
        'should call AddCategoryUseCase and then emit GetAllCategoriesEvent on success',
        () async {
      // arrange
      when(mockAddCategoryUseCase(params: any))
          .thenAnswer((_) async => const Success('1'));

      when(mockGetAllCategoriesUseCase(params: any))
          .thenAnswer((_) async => Success([]));

      // act
      bloc.add(const AddCategoryEvent(name: 'Test Category'));

      // Wait for the event to be processed
      await untilCalled(mockAddCategoryUseCase(params: any));

      // assert
      verify(mockAddCategoryUseCase(params: any));

      // Wait for the GetAllCategoriesEvent to be processed
      await untilCalled(mockGetAllCategoriesUseCase(params: any));

      // Verify that GetAllCategoriesUseCase was called
      verify(mockGetAllCategoriesUseCase(params: any));
    });

    test('should emit CategoryError when adding category fails', () async {
      // arrange
      when(mockAddCategoryUseCase(params: any)).thenAnswer(
          (_) async => Error(DatabaseFailure(message: 'Test error')));

      // assert later
      expectLater(
        bloc.stream,
        emits(CategoryError(message: 'Exception: Test error')),
      );

      // act
      bloc.add(const AddCategoryEvent(name: 'Test Category'));
    });
  });

  group('SetDefaultCategoriesEvent', () {
    test(
        'should call SetDefaultCategoriesUseCase and then emit GetAllCategoriesEvent on success',
        () async {
      // arrange
      when(mockSetDefaultCategoriesUseCase(params: any))
          .thenAnswer((_) async => const Success(null));

      when(mockGetAllCategoriesUseCase(params: any))
          .thenAnswer((_) async => Success([]));

      // act
      bloc.add(SetDefaultCategoriesEvent());

      // Wait for the event to be processed
      await untilCalled(mockSetDefaultCategoriesUseCase(params: any));

      // assert
      verify(mockSetDefaultCategoriesUseCase(params: NoParams()));

      // Wait for the GetAllCategoriesEvent to be processed
      await untilCalled(mockGetAllCategoriesUseCase(params: any));

      // Verify that GetAllCategoriesUseCase was called
      verify(mockGetAllCategoriesUseCase(params: any));
    });

    test('should emit CategoryError when setting default categories fails',
        () async {
      // arrange
      when(mockSetDefaultCategoriesUseCase(params: any)).thenAnswer(
          (_) async => Error(DatabaseFailure(message: 'Test error')));

      // assert later
      expectLater(
        bloc.stream,
        emits(CategoryError(message: 'Exception: Test error')),
      );

      // act
      bloc.add(SetDefaultCategoriesEvent());
    });
  });
}
