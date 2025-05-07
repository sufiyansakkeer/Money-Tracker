import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:money_track/core/utils/currency_formatter.dart';
import 'package:money_track/features/profile/domain/entities/currency_entity.dart';
import 'package:money_track/features/profile/presentation/bloc/currency/currency_cubit.dart';
import 'package:money_track/features/profile/presentation/bloc/currency/currency_state.dart';

// Mock class for CurrencyCubit
class MockCurrencyCubit extends Mock implements CurrencyCubit {}

void main() {
  group('CurrencyFormatter', () {
    late MockCurrencyCubit mockCurrencyCubit;
    late Widget testWidget;

    setUp(() {
      mockCurrencyCubit = MockCurrencyCubit();

      testWidget = MaterialApp(
        home: BlocProvider<CurrencyCubit>.value(
          value: mockCurrencyCubit,
          child: Builder(
            builder: (context) {
              return Scaffold(
                body: TextButton(
                  onPressed: () {
                    // This will trigger the format method
                    CurrencyFormatter.format(context, 100.50);
                  },
                  child: const Text('Test'),
                ),
              );
            },
          ),
        ),
      );
    });

    testWidgets('format returns formatted currency when currency is loaded',
        (WidgetTester tester) async {
      // Arrange
      final currencyEntity = CurrencyEntity(
        code: 'USD',
        name: 'US Dollar',
        symbol: '\$',
        conversionRate: 1.0,
      );

      when(mockCurrencyCubit.state).thenReturn(
        CurrenciesLoaded(
          selectedCurrency: currencyEntity,
          currencies: [currencyEntity],
        ),
      );

      // Act
      await tester.pumpWidget(testWidget);

      // Create a BuildContext to test the formatter
      final BuildContext context = tester.element(find.byType(TextButton));

      // Assert
      expect(
        CurrencyFormatter.format(context, 100.50),
        equals('\$100.50'),
      );

      // Test with sign for income
      expect(
        CurrencyFormatter.format(context, 100.50,
            showSign: true, isExpense: false),
        equals('+ \$100.50'),
      );

      // Test with sign for expense
      expect(
        CurrencyFormatter.format(context, 100.50,
            showSign: true, isExpense: true),
        equals('- \$100.50'),
      );
    });

    testWidgets('format returns default format when currency is not loaded',
        (WidgetTester tester) async {
      // Arrange
      when(mockCurrencyCubit.state).thenReturn(CurrencyInitial());

      // Act
      await tester.pumpWidget(testWidget);

      // Create a BuildContext to test the formatter
      final BuildContext context = tester.element(find.byType(TextButton));

      // Assert
      expect(
        CurrencyFormatter.format(context, 100.50),
        equals('₹100.50'),
      );
    });

    testWidgets('getSelectedCurrency returns currency when loaded',
        (WidgetTester tester) async {
      // Arrange
      final currencyEntity = CurrencyEntity(
        code: 'USD',
        name: 'US Dollar',
        symbol: '\$',
        conversionRate: 1.0,
      );

      when(mockCurrencyCubit.state).thenReturn(
        CurrenciesLoaded(
          selectedCurrency: currencyEntity,
          currencies: [currencyEntity],
        ),
      );

      // Act
      await tester.pumpWidget(testWidget);

      // Create a BuildContext to test the formatter
      final BuildContext context = tester.element(find.byType(TextButton));

      // Assert
      expect(
        CurrencyFormatter.getSelectedCurrency(context),
        equals(currencyEntity),
      );
    });

    testWidgets('getSelectedCurrency returns null when not loaded',
        (WidgetTester tester) async {
      // Arrange
      when(mockCurrencyCubit.state).thenReturn(CurrencyInitial());

      // Act
      await tester.pumpWidget(testWidget);

      // Create a BuildContext to test the formatter
      final BuildContext context = tester.element(find.byType(TextButton));

      // Assert
      expect(
        CurrencyFormatter.getSelectedCurrency(context),
        isNull,
      );
    });

    testWidgets('getCurrencySymbol returns symbol when loaded',
        (WidgetTester tester) async {
      // Arrange
      final currencyEntity = CurrencyEntity(
        code: 'USD',
        name: 'US Dollar',
        symbol: '\$',
        conversionRate: 1.0,
      );

      when(mockCurrencyCubit.state).thenReturn(
        CurrenciesLoaded(
          selectedCurrency: currencyEntity,
          currencies: [currencyEntity],
        ),
      );

      // Act
      await tester.pumpWidget(testWidget);

      // Create a BuildContext to test the formatter
      final BuildContext context = tester.element(find.byType(TextButton));

      // Assert
      expect(
        CurrencyFormatter.getCurrencySymbol(context),
        equals('\$'),
      );
    });

    testWidgets('getCurrencySymbol returns default symbol when not loaded',
        (WidgetTester tester) async {
      // Arrange
      when(mockCurrencyCubit.state).thenReturn(CurrencyInitial());

      // Act
      await tester.pumpWidget(testWidget);

      // Create a BuildContext to test the formatter
      final BuildContext context = tester.element(find.byType(TextButton));

      // Assert
      expect(
        CurrencyFormatter.getCurrencySymbol(context),
        equals('₹'),
      );
    });
  });
}
