import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:money_track/app/app.dart';
import 'package:money_track/app/di/injection_container.dart';
import 'package:money_track/data/models/category_model.dart';
import 'package:money_track/data/models/sync/sync_operation_model.dart';
import 'package:money_track/data/adapters/timestamp_adapter.dart';
import 'package:money_track/features/budget/data/models/budget_model.dart';
import 'package:money_track/features/profile/data/models/currency_model.dart';
import 'package:money_track/firebase_options.dart';
import 'package:money_track/hive_registrar.g.dart';

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

  // Initialize Firebase with error handling
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint('Firebase initialized successfully');
  } catch (e) {
    debugPrint('Firebase initialization error: $e');
    // Re-throw the error to prevent the app from continuing with broken Firebase
    rethrow;
  }

  // Enable edge-to-edge display
  await SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.edgeToEdge,
    overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom],
  );

  // Initialize Hive database
  await Hive.initFlutter();

  // Register all Hive adapters using the generated registrar
  Hive.registerAdapters();

  // Register Timestamp adapter for Firestore compatibility
  if (!Hive.isAdapterRegistered(20)) {
    Hive.registerAdapter(TimestampAdapter());
  }

  // Now open the boxes
  await Hive.openBox<CategoryModel>('category-database');
  await Hive.openBox<CurrencyModel>('currency-database');
  await Hive.openBox<BudgetModel>('budget-database');
  await Hive.openBox<SyncOperationModel>('sync-operations');

  // Initialize dependency injection
  await initializeDependencies();

  // Run the app
  runApp(const App());
}
