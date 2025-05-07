import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:mockito/annotations.dart';
import 'package:money_track/data/datasources/local/category_local_datasource.dart';
import 'package:money_track/data/datasources/local/transaction_local_datasource.dart';
import 'package:money_track/domain/repositories/category_repository.dart';
import 'package:money_track/domain/repositories/transaction_repository.dart';
import 'package:money_track/features/budget/domain/repositories/budget_repository.dart';
import 'package:money_track/features/profile/domain/repositories/currency_repository.dart';
import 'package:money_track/features/profile/domain/repositories/theme_repository.dart';

// Generate mocks for these classes
@GenerateMocks([
  CategoryRepository,
  TransactionRepository,
  CurrencyRepository,
  ThemeRepository,
  BudgetRepository,
  CategoryLocalDataSource,
  TransactionLocalDataSource,
  Box,
])
void main() {}

/// Wraps a widget with MaterialApp for testing
Widget makeTestableWidget({required Widget child}) {
  return MaterialApp(
    home: child,
  );
}

/// Wraps a widget with MaterialApp and necessary BlocProviders for testing
Widget makeTestableWidgetWithBloc({
  required Widget child,
  required List<BlocProvider> providers,
}) {
  return MaterialApp(
    home: MultiBlocProvider(
      providers: providers,
      child: child,
    ),
  );
}
