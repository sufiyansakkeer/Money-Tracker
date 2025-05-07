import 'package:mockito/annotations.dart';
import 'package:money_track/data/datasources/local/category_local_datasource.dart';
import 'package:money_track/data/datasources/local/transaction_local_datasource.dart';
import 'package:money_track/domain/repositories/category_repository.dart';
import 'package:money_track/domain/repositories/transaction_repository.dart';
import 'package:money_track/domain/usecases/category/add_category_usecase.dart';
import 'package:money_track/domain/usecases/category/get_all_categories_usecase.dart';
import 'package:money_track/domain/usecases/category/set_default_categories_usecase.dart';
import 'package:money_track/domain/usecases/transaction/add_transaction_usecase.dart';
import 'package:money_track/domain/usecases/transaction/delete_transaction_usecase.dart';
import 'package:money_track/domain/usecases/transaction/edit_transaction_usecase.dart';
import 'package:money_track/domain/usecases/transaction/get_all_transactions_usecase.dart';
import 'package:money_track/features/budget/domain/repositories/budget_repository.dart';
import 'package:money_track/features/budget/domain/usecases/add_budget_usecase.dart';
import 'package:money_track/features/budget/domain/usecases/get_all_budgets_usecase.dart';
import 'package:money_track/features/profile/domain/repositories/currency_repository.dart';
import 'package:money_track/features/profile/domain/repositories/theme_repository.dart';
import 'package:money_track/features/profile/presentation/bloc/currency/currency_cubit.dart';
import 'package:money_track/features/profile/presentation/bloc/theme/theme_cubit.dart';

@GenerateMocks([
  // Repositories
  CategoryRepository,
  TransactionRepository,
  BudgetRepository,
  CurrencyRepository,
  ThemeRepository,
  
  // Data sources
  CategoryLocalDataSource,
  TransactionLocalDataSource,
  
  // Use cases - Category
  GetAllCategoriesUseCase,
  AddCategoryUseCase,
  SetDefaultCategoriesUseCase,
  
  // Use cases - Transaction
  GetAllTransactionsUseCase,
  AddTransactionUseCase,
  EditTransactionUseCase,
  DeleteTransactionUseCase,
  
  // Use cases - Budget
  GetAllBudgetsUseCase,
  AddBudgetUseCase,
  
  // Cubits
  CurrencyCubit,
  ThemeCubit,
])
void main() {
  // This file is used to generate mock classes
}
