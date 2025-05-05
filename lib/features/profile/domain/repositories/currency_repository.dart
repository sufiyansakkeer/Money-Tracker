import 'package:money_track/core/error/result.dart';
import 'package:money_track/features/profile/domain/entities/currency_entity.dart';

/// Repository interface for currency-related operations
abstract class CurrencyRepository {
  /// Get the currently selected currency
  Future<Result<CurrencyEntity>> getSelectedCurrency();

  /// Set the selected currency
  Future<Result<void>> setSelectedCurrency(String currencyCode);

  /// Get all available currencies
  Future<Result<List<CurrencyEntity>>> getAvailableCurrencies();

  /// Convert an amount from one currency to another
  Future<Result<double>> convertCurrency({
    required double amount,
    required String fromCurrencyCode,
    required String toCurrencyCode,
  });
}
