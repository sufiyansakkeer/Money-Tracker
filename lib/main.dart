import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:money_track/app/app.dart';
import 'package:money_track/app/di/injection_container.dart';
import 'package:money_track/core/logging/app_logger.dart';
import 'package:money_track/data/models/category_model.dart';
import 'package:money_track/data/models/transaction_model.dart';
import 'package:money_track/features/budget/data/models/budget_model.dart';
import 'package:money_track/features/profile/data/models/currency_model.dart';

/// Main entry point for the application
Future<void> main() async {
  // Set system UI overlay style for a modern immersive look
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    systemStatusBarContrastEnforced: false,
    statusBarColor: Colors.transparent,
    systemNavigationBarColor: Colors.transparent,
    systemNavigationBarDividerColor: Colors.transparent,
    systemNavigationBarIconBrightness: Brightness.dark,
    statusBarIconBrightness: Brightness.dark,
    statusBarBrightness: Brightness.light,
  ));

  // Ensure Flutter binding is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize AppLogger first
  AppLogger().initialize(enableFileLogging: false);
  AppLogger().info('Application starting up', tag: 'MAIN');

  // Enable edge-to-edge display
  await SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.edgeToEdge,
    overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom],
  );

  // Initialize Hive database
  AppLogger().info('Initializing Hive database', tag: 'MAIN');
  await Hive.initFlutter();

  // Register Hive adapters BEFORE opening boxes
  AppLogger().debug('Registering Hive adapters', tag: 'MAIN');
  if (!Hive.isAdapterRegistered(CategoryTypeAdapter().typeId)) {
    Hive.registerAdapter(CategoryTypeAdapter());
  }

  if (!Hive.isAdapterRegistered(CategoryModelAdapter().typeId)) {
    Hive.registerAdapter(CategoryModelAdapter());
  }

  Hive.registerAdapter(TransactionModelAdapter());

  if (!Hive.isAdapterRegistered(TransactionTypeAdapter().typeId)) {
    Hive.registerAdapter(TransactionTypeAdapter());
  }

  if (!Hive.isAdapterRegistered(5)) {
    Hive.registerAdapter(CurrencyModelAdapter());
  }

  if (!Hive.isAdapterRegistered(6)) {
    Hive.registerAdapter(BudgetModelAdapter());
  }

  if (!Hive.isAdapterRegistered(7)) {
    Hive.registerAdapter(BudgetPeriodTypeAdapter());
  }

  // Now open the boxes
  AppLogger().debug('Opening Hive boxes', tag: 'MAIN');
  await Hive.openBox<CategoryModel>('category-database');
  await Hive.openBox<CurrencyModel>('currency-database');
  await Hive.openBox<BudgetModel>('budget-database');

  // Initialize dependency injection
  AppLogger().info('Initializing dependency injection', tag: 'MAIN');
  await initializeDependencies();

  // Run the app
  AppLogger().info('Starting MoneyTrack application', tag: 'MAIN');
  runApp(const App());
}