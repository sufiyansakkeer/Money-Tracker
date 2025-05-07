// import 'package:flutter_test/flutter_test.dart';
// import 'package:mockito/annotations.dart';
// import 'package:mockito/mockito.dart';
// import 'package:money_track/core/error/failures.dart';
// import 'package:money_track/core/error/result.dart';
// import 'package:money_track/data/datasources/local/category_local_datasource.dart';
// import 'package:money_track/data/models/category_model.dart' as model;
// import 'package:money_track/data/repositories/category_repository_impl.dart';
// import 'package:money_track/domain/entities/category_entity.dart';
// import 'category_repository_impl_test.mocks.dart';

// // Generate mock for CategoryLocalDataSource
// @GenerateMocks([CategoryLocalDataSource])

// void main() {
//   late CategoryRepositoryImpl repository;
//   late MockCategoryLocalDataSource mockLocalDataSource;

//   setUp(() {
//     mockLocalDataSource = MockCategoryLocalDataSource();
//     repository = CategoryRepositoryImpl(localDataSource: mockLocalDataSource);
//   });

//   group('getAllCategories', () {
//     final tCategoryModels = [
//       model.CategoryModel(
//         id: '1',
//         categoryName: 'Food',
//         type: model.TransactionType.expense,
//         categoryType: model.CategoryType.food,
//       ),
//       model.CategoryModel(
//         id: '2',
//         categoryName: 'Salary',
//         type: model.TransactionType.income,
//         categoryType: model.CategoryType.salary,
//       ),
//     ];

//     final tCategoryEntities = tCategoryModels.map((m) => m.toEntity()).toList();

//     test(
//         'should return list of categories when call to local source is successful',
//         () async {
//       // arrange
//       when(mockLocalDataSource.getAllCategories())
//           .thenAnswer((_) async => tCategoryModels);

//       // act
//       final result = await repository.getAllCategories();

//       // assert
//       verify(mockLocalDataSource.getAllCategories());
//       expect(result, equals(Success(tCategoryEntities)));
//     });

//     test('should return DatabaseFailure when call to local source throws',
//         () async {
//       // arrange
//       when(mockLocalDataSource.getAllCategories())
//           .thenThrow(Exception('Database error'));

//       // act
//       final result = await repository.getAllCategories();

//       // assert
//       verify(mockLocalDataSource.getAllCategories());
//       expect(result, isA<Error<List<CategoryEntity>>>());
//       expect((result as Error).failure, isA<DatabaseFailure>());
//     });
//   });

//   group('addCategory', () {
//     final tCategoryEntity = CategoryEntity(
//       id: '1',
//       categoryName: 'Food',
//       type: TransactionType.expense,
//       categoryType: CategoryType.food,
//     );

//     final tCategoryModel = model.CategoryModel.fromEntity(tCategoryEntity);

//     test(
//         'should return success with id when call to local source is successful',
//         () async {
//       // arrange
//       when(mockLocalDataSource.addCategory(any)).thenAnswer((_) async => '1');

//       // act
//       final result = await repository.addCategory(tCategoryEntity);

//       // assert
//       verify(mockLocalDataSource.addCategory(tCategoryModel));
//       expect(result, equals(const Success('1')));
//     });

//     test('should return DatabaseFailure when call to local source throws',
//         () async {
//       // arrange
//       when(mockLocalDataSource.addCategory(any))
//           .thenThrow(Exception('Database error'));

//       // act
//       final result = await repository.addCategory(tCategoryEntity);

//       // assert
//       verify(mockLocalDataSource.addCategory(tCategoryModel));
//       expect(result, isA<Error<String>>());
//       expect((result as Error).failure, isA<DatabaseFailure>());
//     });
//   });

//   group('deleteCategory', () {
//     test('should return success when call to local source is successful',
//         () async {
//       // arrange
//       when(mockLocalDataSource.deleteCategory(any)).thenAnswer((_) async => {});

//       // act
//       final result = await repository.deleteCategory('1');

//       // assert
//       verify(mockLocalDataSource.deleteCategory('1'));
//       expect(result, equals(const Success(null)));
//     });

//     test('should return DatabaseFailure when call to local source throws',
//         () async {
//       // arrange
//       when(mockLocalDataSource.deleteCategory(any))
//           .thenThrow(Exception('Database error'));

//       // act
//       final result = await repository.deleteCategory('1');

//       // assert
//       verify(mockLocalDataSource.deleteCategory('1'));
//       expect(result, isA<Error<void>>());
//       expect((result as Error).failure, isA<DatabaseFailure>());
//     });
//   });

//   group('setDefaultCategories', () {
//     test('should return success when call to local source is successful',
//         () async {
//       // arrange
//       when(mockLocalDataSource.setDefaultCategories())
//           .thenAnswer((_) async => {});

//       // act
//       final result = await repository.setDefaultCategories();

//       // assert
//       verify(mockLocalDataSource.setDefaultCategories());
//       expect(result, equals(const Success(null)));
//     });

//     test('should return DatabaseFailure when call to local source throws',
//         () async {
//       // arrange
//       when(mockLocalDataSource.setDefaultCategories())
//           .thenThrow(Exception('Database error'));

//       // act
//       final result = await repository.setDefaultCategories();

//       // assert
//       verify(mockLocalDataSource.setDefaultCategories());
//       expect(result, isA<Error<void>>());
//       expect((result as Error).failure, isA<DatabaseFailure>());
//     });
//   });
// }
