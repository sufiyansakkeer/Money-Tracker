// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_test/flutter_test.dart';
// import 'package:mockito/mockito.dart';
// import 'package:money_track/domain/entities/category_entity.dart';
// import 'package:money_track/features/budget/presentation/bloc/budget_bloc.dart';
// import 'package:money_track/features/categories/presentation/bloc/category_bloc.dart';
// import 'package:money_track/features/transactions/presentation/bloc/total_transaction/total_transaction_cubit.dart';
// import 'package:money_track/features/transactions/presentation/bloc/transaction_bloc.dart';
// import 'package:money_track/features/transactions/presentation/pages/add_transaction/transaction_page.dart';

// // Mock classes
// class MockCategoryBloc extends Mock implements CategoryBloc {}
// class MockTransactionBloc extends Mock implements TransactionBloc {}
// class MockTotalTransactionCubit extends Mock implements TotalTransactionCubit {}
// class MockBudgetBloc extends Mock implements BudgetBloc {}

// void main() {
//   late MockCategoryBloc categoryBloc;
//   late MockTransactionBloc transactionBloc;
//   late MockTotalTransactionCubit totalTransactionCubit;
//   late MockBudgetBloc budgetBloc;

//   setUp(() {
//     categoryBloc = MockCategoryBloc();
//     transactionBloc = MockTransactionBloc();
//     totalTransactionCubit = MockTotalTransactionCubit();
//     budgetBloc = MockBudgetBloc();
//   });

//   testWidgets('Transaction flow - Add transaction', (WidgetTester tester) async {
//     // Arrange
//     final categories = [
//       CategoryEntity(
//         id: '1',
//         categoryName: 'Food',
//         type: TransactionType.expense,
//         categoryType: CategoryType.food,
//       ),
//       CategoryEntity(
//         id: '2',
//         categoryName: 'Salary',
//         type: TransactionType.income,
//         categoryType: CategoryType.salary,
//       ),
//     ];
    
//     when(categoryBloc.state).thenReturn(CategoryLoaded(categoryList: categories));
    
//     // Act
//     await tester.pumpWidget(
//       MaterialApp(
//         home: MultiBlocProvider(
//           providers: [
//             BlocProvider<CategoryBloc>.value(value: categoryBloc),
//             BlocProvider<TransactionBloc>.value(value: transactionBloc),
//             BlocProvider<TotalTransactionCubit>.value(value: totalTransactionCubit),
//             BlocProvider<BudgetBloc>.value(value: budgetBloc),
//           ],
//           child: const TransactionPage(isExpense: true),
//         ),
//       ),
//     );
    
//     // Wait for the widget to rebuild
//     await tester.pumpAndSettle();
    
//     // Verify that the transaction page is displayed
//     expect(find.byType(TransactionPage), findsOneWidget);
//     expect(find.text('Expense'), findsOneWidget);
    
//     // Test entering an amount
//     await tester.enterText(find.byType(TextField).first, '100');
//     await tester.pumpAndSettle();
    
//     // Test selecting a category
//     await tester.tap(find.byType(TextFormField).first);
//     await tester.pumpAndSettle();
    
//     // Find and tap on the Food category in the bottom sheet
//     await tester.tap(find.text('Food').last);
//     await tester.pumpAndSettle();
    
//     // Test entering a description
//     await tester.enterText(find.byType(TextFormField).last, 'Lunch');
//     await tester.pumpAndSettle();
    
//     // Test tapping the continue button
//     await tester.tap(find.text('Continue'));
//     await tester.pumpAndSettle();
    
//     // Verify that the add transaction event was triggered
//     verify(transactionBloc.add(any)).called(1);
//   });
// }
