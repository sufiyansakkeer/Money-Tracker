import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_ce/hive.dart';
import 'package:money_track/core/services/connectivity_service.dart';
import 'package:money_track/core/services/sync_service.dart';
import 'package:money_track/data/datasources/local/category_local_datasource.dart';
import 'package:money_track/data/datasources/local/transaction_local_datasource.dart';
import 'package:money_track/data/datasources/remote/category_remote_datasource.dart';
import 'package:money_track/data/datasources/remote/transaction_remote_datasource.dart';
import 'package:money_track/data/repositories/sync_category_repository_impl.dart';
import 'package:money_track/data/repositories/sync_transaction_repository_impl.dart';
import 'package:money_track/domain/repositories/category_repository.dart';
import 'package:money_track/domain/repositories/transaction_repository.dart';
import 'package:money_track/domain/usecases/category/add_category_usecase.dart';
import 'package:money_track/domain/usecases/category/get_all_categories_usecase.dart';
import 'package:money_track/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:money_track/features/auth/data/repositories/sync_auth_repository_impl.dart';
import 'package:money_track/features/auth/domain/repositories/auth_repository.dart';
import 'package:money_track/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:money_track/features/auth/domain/usecases/is_signed_in_usecase.dart';
import 'package:money_track/features/auth/domain/usecases/send_password_reset_usecase.dart';
import 'package:money_track/features/auth/domain/usecases/sign_in_usecase.dart';
import 'package:money_track/features/auth/domain/usecases/sign_out_usecase.dart';
import 'package:money_track/features/auth/domain/usecases/sign_up_usecase.dart';
import 'package:money_track/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:money_track/domain/usecases/category/set_default_categories_usecase.dart';
import 'package:money_track/domain/usecases/transaction/add_transaction_usecase.dart';
import 'package:money_track/domain/usecases/transaction/delete_transaction_usecase.dart';
import 'package:money_track/domain/usecases/transaction/edit_transaction_usecase.dart';
import 'package:money_track/domain/usecases/transaction/get_all_transactions_usecase.dart';
import 'package:money_track/features/budget/data/datasources/budget_local_datasource.dart';
import 'package:money_track/features/budget/data/repositories/budget_repository_impl.dart';
import 'package:money_track/features/budget/domain/repositories/budget_repository.dart';
import 'package:money_track/features/budget/domain/usecases/add_budget_usecase.dart';
import 'package:money_track/features/budget/domain/usecases/delete_budget_usecase.dart';
import 'package:money_track/features/budget/domain/usecases/edit_budget_usecase.dart';
import 'package:money_track/features/budget/domain/usecases/get_active_budgets_usecase.dart';
import 'package:money_track/features/budget/domain/usecases/get_all_budgets_usecase.dart';
import 'package:money_track/features/budget/domain/usecases/get_budgets_by_category_usecase.dart';
import 'package:money_track/features/budget/presentation/bloc/budget_bloc.dart';
import 'package:money_track/features/categories/presentation/bloc/category_bloc.dart';
import 'package:money_track/features/navigation/presentation/bloc/bottom_navigation_bloc.dart';
import 'package:money_track/features/profile/data/datasources/currency_local_datasource.dart';
import 'package:money_track/features/profile/data/datasources/theme_local_datasource.dart';
import 'package:money_track/features/profile/data/repositories/currency_repository_impl.dart';
import 'package:money_track/features/profile/data/repositories/theme_repository_impl.dart';
import 'package:money_track/features/profile/domain/repositories/currency_repository.dart';
import 'package:money_track/features/profile/domain/repositories/theme_repository.dart';
import 'package:money_track/features/profile/domain/usecases/convert_currency_usecase.dart';
import 'package:money_track/features/profile/domain/usecases/get_available_currencies_usecase.dart';
import 'package:money_track/features/profile/domain/usecases/get_selected_currency_usecase.dart';
import 'package:money_track/features/profile/domain/usecases/get_selected_theme_mode_usecase.dart';
import 'package:money_track/features/profile/domain/usecases/get_selected_theme_usecase.dart';
import 'package:money_track/features/profile/domain/usecases/get_theme_settings_usecase.dart';
import 'package:money_track/features/profile/domain/usecases/set_selected_currency_usecase.dart';
import 'package:money_track/features/profile/domain/usecases/set_selected_theme_mode_usecase.dart';
import 'package:money_track/features/profile/domain/usecases/set_selected_theme_usecase.dart';
import 'package:money_track/features/profile/domain/usecases/set_theme_settings_usecase.dart';
import 'package:money_track/core/presentation/bloc/sync_cubit.dart';
import 'package:money_track/features/profile/presentation/bloc/currency/currency_cubit.dart';
import 'package:money_track/features/profile/presentation/bloc/theme/theme_cubit.dart';
import 'package:money_track/features/transactions/presentation/bloc/total_transaction/total_transaction_cubit.dart';
import 'package:money_track/features/transactions/presentation/bloc/transaction_bloc.dart';

/// Enhanced Dependency Injection using get_it for better testability and maintainability
final GetIt sl = GetIt.instance;

/// Initialize all dependencies
Future<void> initializeDependencies() async {
  await _initExternalDependencies();
  _initDataSources();
  _initRepositories();
  _initUseCases();
  _initServices();
  _initBlocs();
}

/// Initialize external dependencies
Future<void> _initExternalDependencies() async {
  // Register Hive
  sl.registerLazySingleton<HiveInterface>(() => Hive);

  // Register Firebase Auth
  sl.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);

  // Register Firebase Firestore
  sl.registerLazySingleton<FirebaseFirestore>(() => FirebaseFirestore.instance);

  // Register Connectivity
  sl.registerLazySingleton<Connectivity>(() => Connectivity());

  // Register Flutter Local Notifications
  // sl.registerLazySingleton<FlutterLocalNotificationsPlugin>(
  //   () => FlutterLocalNotificationsPlugin(),
  // );
}

/// Initialize data sources
void _initDataSources() {
  // Category data source
  sl.registerLazySingleton<CategoryLocalDataSource>(
    () => CategoryLocalDataSourceImpl(hive: sl()),
  );

  // Transaction data source
  sl.registerLazySingleton<TransactionLocalDataSource>(
    () => TransactionLocalDataSourceImpl(hive: sl()),
  );

  // Currency data source
  sl.registerLazySingleton<CurrencyLocalDataSource>(
    () => CurrencyLocalDataSourceImpl(hive: sl()),
  );

  // Theme data source
  sl.registerLazySingleton<ThemeLocalDataSource>(
    () => ThemeLocalDataSourceImpl(),
  );

  // Budget data source
  sl.registerLazySingleton<BudgetLocalDataSource>(
    () => BudgetLocalDataSourceImpl(hive: sl()),
  );

  // Remote data sources
  sl.registerLazySingleton<TransactionRemoteDataSource>(
    () => TransactionRemoteDataSourceImpl(firestore: sl()),
  );
  sl.registerLazySingleton<CategoryRemoteDataSource>(
    () => CategoryRemoteDataSourceImpl(firestore: sl()),
  );

  // Auth remote data source
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(firebaseAuth: sl()),
  );
}

/// Initialize repositories
void _initRepositories() {
  // Category repository (sync-enabled)
  sl.registerLazySingleton<CategoryRepository>(
    () => SyncCategoryRepositoryImpl(
      localDataSource: sl(),
      syncService: sl(),
      authBloc: sl(),
    ),
  );

  // Transaction repository (sync-enabled)
  sl.registerLazySingleton<TransactionRepository>(
    () => SyncTransactionRepositoryImpl(
      localDataSource: sl(),
      syncService: sl(),
      authBloc: sl(),
    ),
  );

  // Currency repository
  sl.registerLazySingleton<CurrencyRepository>(
    () => CurrencyRepositoryImpl(localDataSource: sl()),
  );

  // Theme repository
  sl.registerLazySingleton<ThemeRepository>(
    () => ThemeRepositoryImpl(localDataSource: sl()),
  );

  // Budget repository
  sl.registerLazySingleton<BudgetRepository>(
    () => BudgetRepositoryImpl(localDataSource: sl()),
  );

  // Auth repository (enhanced with sync)
  sl.registerLazySingleton<AuthRepository>(
    () => SyncAuthRepositoryImpl(
      remoteDataSource: sl(),
      syncService: sl(),
      connectivityService: sl(),
    ),
  );
}

/// Initialize use cases
void _initUseCases() {
  // Category use cases
  sl.registerLazySingleton(() => GetAllCategoriesUseCase(sl()));
  sl.registerLazySingleton(() => AddCategoryUseCase(sl()));
  sl.registerLazySingleton(() => SetDefaultCategoriesUseCase(sl()));

  // Transaction use cases
  sl.registerLazySingleton(() => GetAllTransactionsUseCase(sl()));
  sl.registerLazySingleton(() => AddTransactionUseCase(sl()));
  sl.registerLazySingleton(() => EditTransactionUseCase(repository: sl()));
  sl.registerLazySingleton(() => DeleteTransactionUseCase(sl()));

  // Currency use cases
  sl.registerLazySingleton(() => GetSelectedCurrencyUseCase(sl()));
  sl.registerLazySingleton(() => SetSelectedCurrencyUseCase(sl()));
  sl.registerLazySingleton(() => GetAvailableCurrenciesUseCase(sl()));
  sl.registerLazySingleton(() => ConvertCurrencyUseCase(sl()));

  // Theme use cases
  sl.registerLazySingleton(() => GetSelectedThemeUseCase(sl()));
  sl.registerLazySingleton(() => SetSelectedThemeUseCase(sl()));
  sl.registerLazySingleton(() => GetSelectedThemeModeUseCase(sl()));
  sl.registerLazySingleton(() => SetSelectedThemeModeUseCase(sl()));
  sl.registerLazySingleton(() => GetThemeSettingsUseCase(sl()));
  sl.registerLazySingleton(() => SetThemeSettingsUseCase(sl()));

  // Budget use cases
  sl.registerLazySingleton(() => GetAllBudgetsUseCase(sl()));
  sl.registerLazySingleton(() => AddBudgetUseCase(sl()));
  sl.registerLazySingleton(() => EditBudgetUseCase(sl()));
  sl.registerLazySingleton(() => DeleteBudgetUseCase(sl()));
  sl.registerLazySingleton(() => GetBudgetsByCategoryUseCase(sl()));
  sl.registerLazySingleton(() => GetActiveBudgetsUseCase(sl()));

  // Auth use cases
  sl.registerLazySingleton(() => SignInUseCase(sl()));
  sl.registerLazySingleton(() => SignUpUseCase(sl()));
  sl.registerLazySingleton(() => SignOutUseCase(sl()));
  sl.registerLazySingleton(() => GetCurrentUserUseCase(sl()));
  sl.registerLazySingleton(() => IsSignedInUseCase(sl()));
  sl.registerLazySingleton(() => SendPasswordResetUseCase(sl()));
}

/// Initialize services
void _initServices() {
  // Connectivity service
  sl.registerLazySingleton<ConnectivityService>(
    () => ConnectivityService(connectivity: sl()),
  );

  // Sync service
  sl.registerLazySingleton<SyncService>(
    () => SyncService(
      transactionLocalDataSource: sl(),
      categoryLocalDataSource: sl(),
      transactionRemoteDataSource: sl(),
      categoryRemoteDataSource: sl(),
      connectivityService: sl(),
      hive: sl(),
    ),
  );

  // // Budget notification service
  // sl.registerLazySingleton<BudgetNotificationService>(
  //   () => BudgetNotificationService(sl()),
  // );
}

/// Initialize BLoCs (as factories for fresh instances)
void _initBlocs() {
  // Category BLoC
  sl.registerFactory(
    () => CategoryBloc(
      getAllCategoriesUseCase: sl(),
      addCategoryUseCase: sl(),
      setDefaultCategoriesUseCase: sl(),
    ),
  );

  // Transaction BLoC
  sl.registerFactory(
    () => TransactionBloc(
      getAllTransactionsUseCase: sl(),
      addTransactionUseCase: sl(),
      editTransactionUseCase: sl(),
      deleteTransactionUseCase: sl(),
    ),
  );

  // Enhanced Total Transaction Cubit
  sl.registerFactory(
    () => TotalTransactionCubit(
      getAllTransactionsUseCase: sl(),
    ),
  );

  // Bottom Navigation BLoC
  sl.registerFactory(() => BottomNavigationBloc());

  // Currency Cubit
  sl.registerFactory(
    () => CurrencyCubit(
      getSelectedCurrencyUseCase: sl(),
      setSelectedCurrencyUseCase: sl(),
      getAvailableCurrenciesUseCase: sl(),
      convertCurrencyUseCase: sl(),
    ),
  );

  // Theme Cubit
  sl.registerFactory(
    () => ThemeCubit(
      getSelectedThemeUseCase: sl(),
      setSelectedThemeUseCase: sl(),
      getSelectedThemeModeUseCase: sl(),
      setSelectedThemeModeUseCase: sl(),
      getThemeSettingsUseCase: sl(),
      setThemeSettingsUseCase: sl(),
    ),
  );

  // Budget BLoC
  sl.registerFactory(
    () => BudgetBloc(
      getAllBudgetsUseCase: sl(),
      addBudgetUseCase: sl(),
      editBudgetUseCase: sl(),
      deleteBudgetUseCase: sl(),
      getBudgetsByCategoryUseCase: sl(),
      getActiveBudgetsUseCase: sl(),
      getAllTransactionsUseCase: sl(),
    ),
  );

  // Auth BLoC
  sl.registerFactory(
    () => AuthBloc(
      signInUseCase: sl(),
      signUpUseCase: sl(),
      signOutUseCase: sl(),
      getCurrentUserUseCase: sl(),
      isSignedInUseCase: sl(),
      sendPasswordResetUseCase: sl(),
      authRepository: sl(),
    ),
  );

  // Sync Cubit
  sl.registerFactory(
    () => SyncCubit(
      syncService: sl(),
      connectivityService: sl(),
    ),
  );
}

/// Reset all dependencies (useful for testing)
Future<void> resetDependencies() async {
  await sl.reset();
}

/// Check if dependencies are registered
bool isDependencyRegistered<T extends Object>() {
  return sl.isRegistered<T>();
}
