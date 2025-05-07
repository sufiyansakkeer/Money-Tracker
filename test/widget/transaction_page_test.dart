import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:money_track/domain/entities/category_entity.dart';
import 'package:money_track/features/budget/presentation/bloc/budget_bloc.dart';
import 'package:money_track/features/categories/presentation/bloc/category_bloc.dart';
import 'package:money_track/features/transactions/presentation/bloc/total_transaction/total_transaction_cubit.dart';
import 'package:money_track/features/transactions/presentation/bloc/transaction_bloc.dart';
import 'package:money_track/features/transactions/presentation/pages/add_transaction/transaction_page.dart';

// Mock classes
class MockCategoryBloc extends Mock implements CategoryBloc {}
class MockTransactionBloc extends Mock implements TransactionBloc {}
class MockTotalTransactionCubit extends Mock implements TotalTransactionCubit {}
class MockBudgetBloc extends Mock implements BudgetBloc {}

void main() {
  late MockCategoryBloc categoryBloc;
  late MockTransactionBloc transactionBloc;
  late MockTotalTransactionCubit totalTransactionCubit;
  late MockBudgetBloc budgetBloc;

  setUp(() {
    categoryBloc = MockCategoryBloc();
    transactionBloc = MockTransactionBloc();
    totalTransactionCubit = MockTotalTransactionCubit();
    budgetBloc = MockBudgetBloc();
  });

  testWidgets('TransactionPage renders correctly', (WidgetTester tester) async {
    // Arrange
    when(categoryBloc.state).thenReturn(CategoryInitial());
    
    // Act
    await tester.pumpWidget(
      MaterialApp(
        home: MultiBlocProvider(
          providers: [
            BlocProvider<CategoryBloc>.value(value: categoryBloc),
            BlocProvider<TransactionBloc>.value(value: transactionBloc),
            BlocProvider<TotalTransactionCubit>.value(value: totalTransactionCubit),
            BlocProvider<BudgetBloc>.value(value: budgetBloc),
          ],
          child: const TransactionPage(isExpense: true),
        ),
      ),
    );
    
    // Assert
    expect(find.byType(TransactionPage), findsOneWidget);
    expect(find.text('Expense'), findsOneWidget);
    expect(find.byType(TextFormField), findsAtLeastNWidgets(1));
  });

  testWidgets('TransactionPage shows income title when isExpense is false', 
      (WidgetTester tester) async {
    // Arrange
    when(categoryBloc.state).thenReturn(CategoryInitial());
    
    // Act
    await tester.pumpWidget(
      MaterialApp(
        home: MultiBlocProvider(
          providers: [
            BlocProvider<CategoryBloc>.value(value: categoryBloc),
            BlocProvider<TransactionBloc>.value(value: transactionBloc),
            BlocProvider<TotalTransactionCubit>.value(value: totalTransactionCubit),
            BlocProvider<BudgetBloc>.value(value: budgetBloc),
          ],
          child: const TransactionPage(isExpense: false),
        ),
      ),
    );
    
    // Assert
    expect(find.text('Income'), findsOneWidget);
  });

  testWidgets('TransactionPage shows categories when loaded', 
      (WidgetTester tester) async {
    // Arrange
    final categories = [
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
    
    when(categoryBloc.state).thenReturn(CategoryLoaded(categoryList: categories));
    
    // Act
    await tester.pumpWidget(
      MaterialApp(
        home: MultiBlocProvider(
          providers: [
            BlocProvider<CategoryBloc>.value(value: categoryBloc),
            BlocProvider<TransactionBloc>.value(value: transactionBloc),
            BlocProvider<TotalTransactionCubit>.value(value: totalTransactionCubit),
            BlocProvider<BudgetBloc>.value(value: budgetBloc),
          ],
          child: const TransactionPage(isExpense: true),
        ),
      ),
    );
    
    // Tap on the category field to open the bottom sheet
    await tester.tap(find.byType(TextFormField).first);
    await tester.pumpAndSettle();
    
    // Assert that the category bottom sheet is shown
    expect(find.text('Category'), findsNWidgets(2)); // One in the form, one in the bottom sheet
    
    // Check if categories are displayed
    expect(find.text('Food'), findsOneWidget);
  });
}
