import 'package:money_track/core/error/failures.dart';
import 'package:money_track/core/error/result.dart';
import 'package:money_track/features/profile/data/datasources/currency_local_datasource.dart';
import 'package:money_track/features/profile/domain/entities/currency_entity.dart';
import 'package:money_track/features/profile/domain/repositories/currency_repository.dart';

class CurrencyRepositoryImpl implements CurrencyRepository {
  final CurrencyLocalDataSource localDataSource;

  CurrencyRepositoryImpl({required this.localDataSource});

  @override
  Future<Result<CurrencyEntity>> getSelectedCurrency() async {
    try {
      final currencyModel = await localDataSource.getSelectedCurrency();
      return Success(currencyModel.toEntity());
    } catch (e) {
      return Error(DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<void>> setSelectedCurrency(String currencyCode) async {
    try {
      await localDataSource.setSelectedCurrency(currencyCode);
      return const Success(null);
    } catch (e) {
      return Error(DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<List<CurrencyEntity>>> getAvailableCurrencies() async {
    try {
      final currencyModels = await localDataSource.getAvailableCurrencies();
      final currencyEntities = currencyModels.map((model) => model.toEntity()).toList();
      return Success(currencyEntities);
    } catch (e) {
      return Error(DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<double>> convertCurrency({
    required double amount,
    required String fromCurrencyCode,
    required String toCurrencyCode,
  }) async {
    try {
      // Get all available currencies
      final currenciesResult = await getAvailableCurrencies();
      
      if (currenciesResult is Error) {
        return Error(DatabaseFailure(message: 'Failed to get currencies for conversion'));
      }
      
      final currencies = (currenciesResult as Success<List<CurrencyEntity>>).data;
      
      // Find the source and target currencies
      final fromCurrency = currencies.firstWhere(
        (currency) => currency.code == fromCurrencyCode,
        orElse: () => throw Exception('Source currency not found'),
      );
      
      final toCurrency = currencies.firstWhere(
        (currency) => currency.code == toCurrencyCode,
        orElse: () => throw Exception('Target currency not found'),
      );
      
      // Convert to USD first (base currency), then to target currency
      final amountInUSD = amount / fromCurrency.conversionRate;
      final convertedAmount = amountInUSD * toCurrency.conversionRate;
      
      return Success(convertedAmount);
    } catch (e) {
      return Error(DatabaseFailure(message: 'Currency conversion failed: ${e.toString()}'));
    }
  }
}
