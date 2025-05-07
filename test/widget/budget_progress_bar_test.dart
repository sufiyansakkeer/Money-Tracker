import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:money_track/domain/entities/category_entity.dart';
import 'package:money_track/domain/entities/transaction_entity.dart';
import 'package:money_track/features/budget/domain/entities/budget_entity.dart';
import 'package:money_track/features/budget/presentation/widgets/budget_progress_bar.dart';

void main() {
  group('BudgetProgressBar Widget Tests', () {
    testWidgets('renders correctly with low percentage',
        (WidgetTester tester) async {
      // Create a test category
      final category = CategoryEntity(
        id: '1',
        categoryName: 'Food',
        type: TransactionType.expense,
        categoryType: CategoryType.food,
      );

      // Create a test budget
      final budget = BudgetEntity(
        id: '1',
        name: 'Test Budget',
        amount: 1000,
        category: category,
        periodType: BudgetPeriodType.monthly,
        startDate: DateTime.now(),
      );

      // Create test transactions (30% of budget)
      final transactions = [
        TransactionEntity(
          id: '1',
          amount: 300,
          date: DateTime.now(),
          categoryType: CategoryType.food,
          transactionType: TransactionType.expense,
          category: category,
          notes: 'Test Transaction',
        ),
      ];

      // Build the widget
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BudgetProgressBar(
              budget: budget,
              transactions: transactions,
            ),
          ),
        ),
      );

      // Verify the widget renders
      expect(find.text('Test Budget'), findsOneWidget);
      expect(find.text('30.0%'), findsOneWidget);

      // Verify the progress indicator
      final progressIndicator = tester.widget<LinearProgressIndicator>(
        find.byType(LinearProgressIndicator),
      );
      expect(progressIndicator.value, equals(0.3));
      expect(progressIndicator.color, equals(Colors.green));
    });

    testWidgets('renders correctly with medium percentage',
        (WidgetTester tester) async {
      // Create a test category
      final category = CategoryEntity(
        id: '1',
        categoryName: 'Food',
        type: TransactionType.expense,
        categoryType: CategoryType.food,
      );

      // Create a test budget
      final budget = BudgetEntity(
        id: '1',
        name: 'Test Budget',
        amount: 1000,
        category: category,
        periodType: BudgetPeriodType.monthly,
        startDate: DateTime.now(),
      );

      // Create test transactions (75% of budget)
      final transactions = [
        TransactionEntity(
          id: '1',
          amount: 750,
          date: DateTime.now(),
          categoryType: CategoryType.food,
          transactionType: TransactionType.expense,
          category: category,
          notes: 'Test Transaction',
        ),
      ];

      // Build the widget
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BudgetProgressBar(
              budget: budget,
              transactions: transactions,
            ),
          ),
        ),
      );

      // Verify the widget renders
      expect(find.text('Test Budget'), findsOneWidget);
      expect(find.text('75.0%'), findsOneWidget);

      // Verify the progress indicator
      final progressIndicator = tester.widget<LinearProgressIndicator>(
        find.byType(LinearProgressIndicator),
      );
      expect(progressIndicator.value, equals(0.75));
      expect(progressIndicator.color, equals(Colors.orange));
    });

    testWidgets('renders correctly with high percentage',
        (WidgetTester tester) async {
      // Create a test category
      final category = CategoryEntity(
        id: '1',
        categoryName: 'Food',
        type: TransactionType.expense,
        categoryType: CategoryType.food,
      );

      // Create a test budget
      final budget = BudgetEntity(
        id: '1',
        name: 'Test Budget',
        amount: 1000,
        category: category,
        periodType: BudgetPeriodType.monthly,
        startDate: DateTime.now(),
      );

      // Create test transactions (95% of budget)
      final transactions = [
        TransactionEntity(
          id: '1',
          amount: 950,
          date: DateTime.now(),
          categoryType: CategoryType.food,
          transactionType: TransactionType.expense,
          category: category,
          notes: 'Test Transaction',
        ),
      ];

      // Build the widget
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BudgetProgressBar(
              budget: budget,
              transactions: transactions,
            ),
          ),
        ),
      );

      // Verify the widget renders
      expect(find.text('Test Budget'), findsOneWidget);
      expect(find.text('95.0%'), findsOneWidget);

      // Verify the progress indicator
      final progressIndicator = tester.widget<LinearProgressIndicator>(
        find.byType(LinearProgressIndicator),
      );
      expect(progressIndicator.value, equals(0.95));
      expect(progressIndicator.color, equals(Colors.red));
    });

    testWidgets('displays correct spent and remaining amounts',
        (WidgetTester tester) async {
      // Create a test category
      final category = CategoryEntity(
        id: '1',
        categoryName: 'Food',
        type: TransactionType.expense,
        categoryType: CategoryType.food,
      );

      // Create a test budget
      final budget = BudgetEntity(
        id: '1',
        name: 'Test Budget',
        amount: 1000,
        category: category,
        periodType: BudgetPeriodType.monthly,
        startDate: DateTime.now(),
      );

      // Create test transactions (50% of budget)
      final transactions = [
        TransactionEntity(
          id: '1',
          amount: 500,
          date: DateTime.now(),
          categoryType: CategoryType.food,
          transactionType: TransactionType.expense,
          category: category,
          notes: 'Test Transaction',
        ),
      ];

      // Build the widget
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BudgetProgressBar(
              budget: budget,
              transactions: transactions,
            ),
          ),
        ),
      );

      // Verify the spent and remaining amounts
      expect(find.textContaining('Spent: ₹500.00'), findsOneWidget);
      expect(find.textContaining('Remaining: ₹500.00'), findsOneWidget);
      expect(
          find.textContaining('Budget: ₹1,000.00 · MONTHLY'), findsOneWidget);
    });
  });
}
