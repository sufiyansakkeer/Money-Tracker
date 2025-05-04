import 'package:hive/hive.dart';
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
import 'package:money_track/domain/usecases/transaction/get_all_transactions_usecase.dart';
import 'package:money_track/features/categories/presentation/bloc/category_bloc.dart';
import 'package:money_track/features/navigation/presentation/bloc/bottom_navigation_bloc.dart';
import 'package:money_track/features/profile/data/datasources/currency_local_datasource.dart';
import 'package:money_track/features/profile/data/repositories/currency_repository_impl.dart';
import 'package:money_track/features/profile/domain/repositories/currency_repository.dart';
import 'package:money_track/features/profile/domain/usecases/convert_currency_usecase.dart';
import 'package:money_track/features/profile/domain/usecases/get_available_currencies_usecase.dart';
import 'package:money_track/features/profile/domain/usecases/get_selected_currency_usecase.dart';
import 'package:money_track/features/profile/domain/usecases/set_selected_currency_usecase.dart';
import 'package:money_track/features/profile/presentation/bloc/currency/currency_cubit.dart';
import 'package:money_track/features/transactions/presentation/bloc/total_transaction/total_transaction_cubit.dart';
import 'package:money_track/features/transactions/presentation/bloc/transaction_bloc.dart';

/// Service locator instance
final sl = _ServiceLocator();

class _ServiceLocator {
  // Singleton instance
  static final _ServiceLocator _instance = _ServiceLocator._internal();

  // Factory constructor
  factory _ServiceLocator() {
    return _instance;
  }

  // Internal constructor
  _ServiceLocator._internal();

  // Dependencies
  late CategoryBloc categoryBloc;
  late TransactionBloc transactionBloc;
  late TotalTransactionCubit totalTransactionCubit;
  late BottomNavigationBloc bottomNavigationBloc;
  late CurrencyCubit currencyCubit;

  // Initialize dependencies
  Future<void> init() async {
    // External dependencies
    final hive = Hive;

    // Data sources
    final categoryLocalDataSource = CategoryLocalDataSourceImpl(hive: hive);
    final transactionLocalDataSource =
        TransactionLocalDataSourceImpl(hive: hive);
    final currencyLocalDataSource = CurrencyLocalDataSourceImpl(hive: hive);

    // Repositories
    final CategoryRepository categoryRepository = CategoryRepositoryImpl(
      localDataSource: categoryLocalDataSource,
    );
    final TransactionRepository transactionRepository =
        TransactionRepositoryImpl(
      localDataSource: transactionLocalDataSource,
    );
    final CurrencyRepository currencyRepository = CurrencyRepositoryImpl(
      localDataSource: currencyLocalDataSource,
    );

    // Use cases
    final getAllCategoriesUseCase = GetAllCategoriesUseCase(categoryRepository);
    final addCategoryUseCase = AddCategoryUseCase(categoryRepository);
    final setDefaultCategoriesUseCase =
        SetDefaultCategoriesUseCase(categoryRepository);
    final getAllTransactionsUseCase =
        GetAllTransactionsUseCase(transactionRepository);
    final addTransactionUseCase = AddTransactionUseCase(transactionRepository);

    // Currency use cases
    final getSelectedCurrencyUseCase =
        GetSelectedCurrencyUseCase(currencyRepository);
    final setSelectedCurrencyUseCase =
        SetSelectedCurrencyUseCase(currencyRepository);
    final getAvailableCurrenciesUseCase =
        GetAvailableCurrenciesUseCase(currencyRepository);
    final convertCurrencyUseCase = ConvertCurrencyUseCase(currencyRepository);

    // BLoCs
    categoryBloc = CategoryBloc(
      getAllCategoriesUseCase: getAllCategoriesUseCase,
      addCategoryUseCase: addCategoryUseCase,
      setDefaultCategoriesUseCase: setDefaultCategoriesUseCase,
    );

    transactionBloc = TransactionBloc(
      getAllTransactionsUseCase: getAllTransactionsUseCase,
      addTransactionUseCase: addTransactionUseCase,
    );

    totalTransactionCubit = TotalTransactionCubit(
      getAllTransactionsUseCase: getAllTransactionsUseCase,
    );

    bottomNavigationBloc = BottomNavigationBloc();

    currencyCubit = CurrencyCubit(
      getSelectedCurrencyUseCase: getSelectedCurrencyUseCase,
      setSelectedCurrencyUseCase: setSelectedCurrencyUseCase,
      getAvailableCurrenciesUseCase: getAvailableCurrenciesUseCase,
      convertCurrencyUseCase: convertCurrencyUseCase,
    );
  }
}
