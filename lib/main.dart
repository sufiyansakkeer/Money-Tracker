import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:money_track/app/app.dart';
import 'package:money_track/app/di/injection_container.dart';
import 'package:money_track/data/models/category_model.dart';
import 'package:money_track/data/models/transaction_model.dart';

/// Main entry point for the application
Future<void> main() async {
  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    systemStatusBarContrastEnforced: true,
    systemNavigationBarColor: Colors.transparent,
    systemNavigationBarDividerColor: Colors.transparent,
    systemNavigationBarIconBrightness: Brightness.dark,
    statusBarIconBrightness: Brightness.light,
  ));

  // Ensure Flutter binding is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive database
  await Hive.initFlutter();

  // Register Hive adapters BEFORE opening boxes
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

  // Now open the boxes
  await Hive.openBox<CategoryModel>('category-database');

  // Initialize dependency injection
  await sl.init();

  // Run the app
  runApp(const App());
}
