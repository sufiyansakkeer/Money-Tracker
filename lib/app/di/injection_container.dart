import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';
import 'package:money_track/core/logging/app_logger.dart';
import 'package:money_track/data/datasources/local/category_local_datasource.dart';
import 'package:money_track/data/datasources/local/transaction_local_datasource.dart';
import 'package:money_track/data/repositories/category_repository_impl.dart';
import 'package:money_track/data/repositories/transaction_repository_impl.dart';
import 'package:money_track/domain/repositories/category_repository.dart';
import 'package:money_track/domain/repositories/transaction_repository.dart';
import 'package:money_track/domain/usecases/category/add_category_usecase.dart';
import 'package:money_track/domain/usecases/category/get_all_categories_usecase.dart';
import 'package:money_track/domain/usecases/category/set_default_categories_usecase.dart';
import 'package:money_track/domain/usecases/transaction/add_transaction_usecase.dart';
import 'package:money_track/domain/usecases/transaction/delete_transaction_usecase.dart';
import 'package:money_track/domain/usecases/transaction/edit_transaction_usecase.dart';
import 'package:money_track/domain/usecases/transaction/get_all_transactions_usecase.dart';
import 'package:money_track/features/budget/data/datasources/budget_local_datasource.dart';
import 'package:money_track/features/budget/data/repositories/budget_repository_impl.dart';
import 'package:money_track/features/budget/domain/repositories/budget_repository.dart';
import 'package:money_track/features/budget/domain/services/budget_notification_service.dart';
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
import 'package:money_track/features/profile/presentation/bloc/currency/currency_cubit.dart';
import 'package:money_track/features/profile/presentation/bloc/theme/theme_cubit.dart';
import 'package:money_track/features/transactions/presentation/bloc/total_transaction/total_transaction_cubit.dart';
import 'package:money_track/features/transactions/presentation/bloc/transaction_bloc.dart';

/// Enhanced Dependency Injection using get_it for better testability and maintainability
final GetIt sl = GetIt.instance;

/// Initialize all dependencies
Future<void> initializeDependencies() async {
  AppLogger().info('Starting dependency initialization', tag: 'DI');
  await _initExternalDependencies();
  _initDataSources();
  _initRepositories();
  _initUseCases();
  _initServices();
  _initBlocs();
  AppLogger().info('Dependency initialization completed', tag: 'DI');
}

/// Initialize external dependencies
Future<void> _initExternalDependencies() async {
  AppLogger().debug('Initializing external dependencies', tag: 'DI');
  
  // Register Hive
  sl.registerLazySingleton<HiveInterface>(() => Hive);

  // Register Flutter Local Notifications
  sl.registerLazySingleton<FlutterLocalNotificationsPlugin>(
    () => FlutterLocalNotificationsPlugin(),
  );
  
  AppLogger().debug('External dependencies initialized', tag: 'DI');
}

/// Initialize data sources
void _initDataSources() {
  AppLogger().debug('Initializing data sources', tag: 'DI');
  
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
  
  AppLogger().debug('Data sources initialized', tag: 'DI');
}

/// Initialize repositories
void _initRepositories() {
  AppLogger().debug('Initializing repositories', tag: 'DI');
  
  // Category repository
  sl.registerLazySingleton<CategoryRepository>(
    () => CategoryRepositoryImpl(localDataSource: sl()),
  );

  // Transaction repository
  sl.registerLazySingleton<TransactionRepository>(
    () => TransactionRepositoryImpl(localDataSource: sl()),
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
  
  AppLogger().debug('Repositories initialized', tag: 'DI');
}

/// Initialize use cases
void _initUseCases() {
  AppLogger().debug('Initializing use cases', tag: 'DI');
  
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
  
  AppLogger().debug('Use cases initialized', tag: 'DI');
}

/// Initialize services
void _initServices() {
  AppLogger().debug('Initializing services', tag: 'DI');
  
  // Budget notification service
  sl.registerLazySingleton<BudgetNotificationService>(
    () => BudgetNotificationService(sl()),
  );
  
  AppLogger().debug('Services initialized', tag: 'DI');
}

/// Initialize BLoCs (as factories for fresh instances)
void _initBlocs() {
  AppLogger().debug('Initializing BLoCs', tag: 'DI');
  
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
      notificationService: sl(),
    ),
  );
  
  AppLogger().debug('BLoCs initialized', tag: 'DI');
}

/// Reset all dependencies (useful for testing)
Future<void> resetDependencies() async {
  AppLogger().info('Resetting dependencies', tag: 'DI');
  await sl.reset();
}

/// Check if dependencies are registered
bool isDependencyRegistered<T extends Object>() {
  return sl.isRegistered<T>();
}