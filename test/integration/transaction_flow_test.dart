// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_test/flutter_test.dart';
// import 'package:hive/hive.dart';
// import 'package:hive_flutter/adapters.dart';
// import 'package:mockito/mockito.dart';
// import 'package:money_track/data/datasources/local/category_local_datasource.dart';
// import 'package:money_track/data/datasources/local/transaction_local_datasource.dart';
// import 'package:money_track/data/models/category_model.dart' as model;
// import 'package:money_track/data/models/transaction_model.dart'
//     as transaction_model;
// import 'package:money_track/data/repositories/category_repository_impl.dart';
// import 'package:money_track/data/repositories/transaction_repository_impl.dart';
// import 'package:money_track/domain/usecases/category/add_category_usecase.dart';
// import 'package:money_track/domain/usecases/category/get_all_categories_usecase.dart';
// import 'package:money_track/domain/usecases/category/set_default_categories_usecase.dart';
// import 'package:money_track/domain/usecases/transaction/add_transaction_usecase.dart';
// import 'package:money_track/domain/usecases/transaction/delete_transaction_usecase.dart';
// import 'package:money_track/domain/usecases/transaction/edit_transaction_usecase.dart';
// import 'package:money_track/domain/usecases/transaction/get_all_transactions_usecase.dart';
// import 'package:money_track/features/categories/presentation/bloc/category_bloc.dart';
// import 'package:money_track/features/transactions/presentation/bloc/total_transaction/total_transaction_cubit.dart';
// import 'package:money_track/features/transactions/presentation/bloc/transaction_bloc.dart';
// import 'package:money_track/features/transactions/presentation/pages/add_transaction/transaction_page.dart';

// class MockHive extends Mock implements HiveInterface {}

// class MockBox<T> extends Mock implements Box<T> {}

// void main() {
//   late MockHive mockHive;
//   late MockBox<model.CategoryModel> mockCategoryBox;
//   late MockBox<transaction_model.TransactionModel> mockTransactionBox;
//   late CategoryLocalDataSource categoryLocalDataSource;
//   late TransactionLocalDataSource transactionLocalDataSource;
//   late CategoryRepositoryImpl categoryRepository;
//   late TransactionRepositoryImpl transactionRepository;
//   late GetAllCategoriesUseCase getAllCategoriesUseCase;
//   late AddCategoryUseCase addCategoryUseCase;
//   late SetDefaultCategoriesUseCase setDefaultCategoriesUseCase;
//   late GetAllTransactionsUseCase getAllTransactionsUseCase;
//   late AddTransactionUseCase addTransactionUseCase;
//   late EditTransactionUseCase editTransactionUseCase;
//   late DeleteTransactionUseCase deleteTransactionUseCase;
//   late CategoryBloc categoryBloc;
//   late TransactionBloc transactionBloc;
//   late TotalTransactionCubit totalTransactionCubit;

//   setUp(() {
//     mockHive = MockHive();
//     mockCategoryBox = MockBox<model.CategoryModel>();
//     mockTransactionBox = MockBox<transaction_model.TransactionModel>();

//     when(mockHive.box<model.CategoryModel>('category-database'))
//         .thenReturn(mockCategoryBox);
//     when(mockHive
//             .box<transaction_model.TransactionModel>('transaction-database'))
//         .thenReturn(mockTransactionBox);

//     categoryLocalDataSource = CategoryLocalDataSourceImpl(hive: mockHive);
//     transactionLocalDataSource = TransactionLocalDataSourceImpl(hive: mockHive);

//     categoryRepository = CategoryRepositoryImpl(
//       localDataSource: categoryLocalDataSource,
//     );
//     transactionRepository = TransactionRepositoryImpl(
//       localDataSource: transactionLocalDataSource,
//     );

//     getAllCategoriesUseCase = GetAllCategoriesUseCase(categoryRepository);
//     addCategoryUseCase = AddCategoryUseCase(categoryRepository);
//     setDefaultCategoriesUseCase =
//         SetDefaultCategoriesUseCase(categoryRepository);

//     getAllTransactionsUseCase =
//         GetAllTransactionsUseCase(transactionRepository);
//     addTransactionUseCase = AddTransactionUseCase(transactionRepository);
//     editTransactionUseCase =
//         EditTransactionUseCase(repository: transactionRepository);
//     deleteTransactionUseCase = DeleteTransactionUseCase(transactionRepository);

//     categoryBloc = CategoryBloc(
//       getAllCategoriesUseCase: getAllCategoriesUseCase,
//       addCategoryUseCase: addCategoryUseCase,
//       setDefaultCategoriesUseCase: setDefaultCategoriesUseCase,
//     );

//     transactionBloc = TransactionBloc(
//       getAllTransactionsUseCase: getAllTransactionsUseCase,
//       addTransactionUseCase: addTransactionUseCase,
//       editTransactionUseCase: editTransactionUseCase,
//       deleteTransactionUseCase: deleteTransactionUseCase,
//     );

//     totalTransactionCubit = TotalTransactionCubit(
//       getAllTransactionsUseCase: getAllTransactionsUseCase,
//     );
//   });

//   testWidgets('Transaction flow - Add transaction',
//       (WidgetTester tester) async {
//     // Mock category data
//     final categories = [
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

//     // Mock transactions data
//     final transactions = <transaction_model.TransactionModel>[];

//     // Setup mock responses
//     when(mockCategoryBox.values).thenAnswer((_) => categories);
//     when(mockTransactionBox.values).thenAnswer((_) => transactions);

//     // Use a custom matcher for the add method
//     when(mockTransactionBox
//             .add(argThat(TypeMatcher<transaction_model.TransactionModel>())))
//         .thenAnswer((_) async => 0);

//     // Build the widget tree
//     await tester.pumpWidget(
//       MaterialApp(
//         home: MultiBlocProvider(
//           providers: [
//             BlocProvider<CategoryBloc>.value(value: categoryBloc),
//             BlocProvider<TransactionBloc>.value(value: transactionBloc),
//             BlocProvider<TotalTransactionCubit>.value(
//                 value: totalTransactionCubit),
//           ],
//           child: const TransactionPage(isExpense: true),
//         ),
//       ),
//     );

//     // Load initial data
//     categoryBloc.add(GetAllCategoriesEvent());
//     transactionBloc.add(GetAllTransactionsEvent());

//     // Wait for the widget to rebuild
//     await tester.pumpAndSettle();

//     // Verify that the transaction page is displayed
//     expect(find.byType(TransactionPage), findsOneWidget);

//     // Test selecting a category
//     await tester.tap(find.text('Food'));
//     await tester.pumpAndSettle();

//     // Test entering an amount
//     await tester.enterText(find.byType(TextField).first, '100');
//     await tester.pumpAndSettle();

//     // Test entering a description
//     await tester.enterText(find.byType(TextField).last, 'Lunch');
//     await tester.pumpAndSettle();

//     // Test tapping the continue button
//     await tester.tap(find.text('Continue'));
//     await tester.pumpAndSettle();

//     // Verify that the transaction was added
//     verify(mockTransactionBox
//             .add(argThat(TypeMatcher<transaction_model.TransactionModel>())))
//         .called(1);
//   });
// }
