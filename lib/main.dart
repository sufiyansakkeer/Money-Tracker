import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:money_track/app/app.dart';
import 'package:money_track/app/di/injection_container.dart';
import 'package:money_track/core/constants/db_constants.dart';
import 'package:money_track/data/models/category_model.dart';
import 'package:money_track/features/budget/data/models/budget_model.dart';
import 'package:money_track/features/groups/data/models/group_model.dart';
import 'package:money_track/features/groups/data/models/split_details_model.dart';
import 'package:money_track/features/profile/data/models/currency_model.dart';
import 'package:money_track/firebase_options.dart';
import 'package:money_track/hive_registrar.g.dart';
import 'package:money_track/features/groups/data/models/split_type_adapter.dart';

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

  // Register custom adapters first
  Hive.registerAdapter(SplitTypeAdapter());

  // Register all Hive adapters using the generated registrar
  Hive.registerAdapters();

  // Now open the boxes
  await Hive.openBox<CategoryModel>(DBConstants.categoryDbName);
  await Hive.openBox<CurrencyModel>(DBConstants.currencyDbName);
  await Hive.openBox<BudgetModel>(DBConstants.budgetDbName);
  await Hive.openBox<GroupModel>(DBConstants.groupDbName);
  await Hive.openBox<SplitDetailsModel>(DBConstants.splitDetailsDbName);

  // Initialize dependency injection
  await initializeDependencies();

  // Run the app
  runApp(const App());
}
