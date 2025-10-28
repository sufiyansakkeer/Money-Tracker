import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:money_track/app/app.dart';
import 'package:money_track/app/di/injection_container.dart';
import 'package:money_track/core/constants/db_constants.dart';
import 'package:money_track/core/services/logger_service.dart';
import 'package:money_track/data/models/category_model.dart';
import 'package:money_track/features/budget/data/models/budget_model.dart';
import 'package:money_track/features/groups/data/models/group_model.dart';
import 'package:money_track/features/groups/data/models/split_details_model.dart';
import 'package:money_track/features/groups/data/models/shared_expense_model.dart';
import 'package:money_track/features/groups/data/models/settlement_model.dart';
import 'package:money_track/features/groups/data/models/group_activity_model.dart';
import 'package:money_track/features/profile/data/models/currency_model.dart';
import 'package:money_track/firebase_options.dart';
import 'package:money_track/hive_registrar.g.dart';
import 'package:money_track/features/groups/data/models/split_type_adapter.dart';

/// Main entry point for the application
Future<void> main() async {
  // Wrap everything inside runZonedGuarded for safe async error handling
  runZonedGuarded<Future<void>>(() async {
    WidgetsFlutterBinding.ensureInitialized();

    // 🌈 Set system UI overlay style for a modern immersive look
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      systemStatusBarContrastEnforced: false,
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarDividerColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.dark,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ));

    // 🔥 Initialize Firebase
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      LoggerService.instance.i('✅ Firebase initialized successfully');
    } catch (e, st) {
      LoggerService.instance
          .e('❌ Firebase initialization failed', error: e, stackTrace: st);
      rethrow; // Prevent app from running with a broken Firebase instance
    }

    // 🧭 Enable edge-to-edge display
    await SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.edgeToEdge,
      overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom],
    );

    // 🗃 Initialize Hive local database
    await Hive.initFlutter();

    // Register custom adapters
    Hive.registerAdapter(SplitTypeAdapter());
    Hive.registerAdapters();

    // Open Hive boxes (local storage)
    try {
      await Hive.openBox<CategoryModel>(DBConstants.categoryDbName);
      await Hive.openBox<CurrencyModel>(DBConstants.currencyDbName);
      await Hive.openBox<BudgetModel>(DBConstants.budgetDbName);
      await Hive.openBox<GroupModel>(DBConstants.groupDbName);
      await Hive.openBox<SplitDetailsModel>(DBConstants.splitDetailsDbName);
      await Hive.openBox<SharedExpenseModel>(DBConstants.sharedExpenseDbName);
      await Hive.openBox<SettlementModel>(DBConstants.settlementDbName);
      await Hive.openBox<GroupActivityModel>(DBConstants.groupActivityDbName);
      LoggerService.instance.i('📦 Hive boxes opened successfully');
    } catch (e, st) {
      LoggerService.instance
          .e('⚠️ Error opening Hive boxes', error: e, stackTrace: st);
      rethrow;
    }

    // 🧩 Initialize dependency injection
    await initializeDependencies();
    LoggerService.instance.i('🔧 Dependencies initialized');

    // 🚀 Run the Flutter app
    LoggerService.instance.i('🎯 Launching MoneyTrack app...');
    runApp(const App());
  }, (error, stackTrace) {
    // 🧱 Global error handler (for uncaught async errors)
    LoggerService.instance.e(
      '💥 Uncaught Zone Error',
      error: error,
      stackTrace: stackTrace,
    );

    // Optional: forward to Firebase Crashlytics or Sentry
    // FirebaseCrashlytics.instance.recordError(error, stackTrace, fatal: true);
  });
}
