import 'dart:developer';

import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:money_track/core/constants/db_constants.dart';
import 'package:money_track/core/error/failures.dart';
import 'package:money_track/features/profile/data/models/currency_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class CurrencyLocalDataSource {
  /// Get the currently selected currency
  Future<CurrencyModel> getSelectedCurrency();

  /// Set the selected currency
  Future<void> setSelectedCurrency(String currencyCode);

  /// Get all available currencies
  Future<List<CurrencyModel>> getAvailableCurrencies();

  /// Set default currencies if none exist
  Future<void> setDefaultCurrencies();
}

class CurrencyLocalDataSourceImpl implements CurrencyLocalDataSource {
  final HiveInterface hive;

  CurrencyLocalDataSourceImpl({required this.hive});

  @override
  Future<CurrencyModel> getSelectedCurrency() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final selectedCurrencyCode =
          prefs.getString('selected_currency') ?? 'USD';

      final currencyBox =
          await hive.openBox<CurrencyModel>(DBConstants.currencyDbName);
      final currencies = currencyBox.values.toList();

      final selectedCurrency = currencies.firstWhere(
        (currency) => currency.code == selectedCurrencyCode,
        orElse: () => _defaultCurrencies.first,
      );

      return selectedCurrency;
    } catch (e) {
      log(e.toString(), name: "Get selected currency exception");
      throw DatabaseFailure(
          message: "Failed to get selected currency: ${e.toString()}");
    }
  }

  @override
  Future<void> setSelectedCurrency(String currencyCode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('selected_currency', currencyCode);
    } catch (e) {
      log(e.toString(), name: "Set selected currency exception");
      throw DatabaseFailure(
          message: "Failed to set selected currency: ${e.toString()}");
    }
  }

  @override
  Future<List<CurrencyModel>> getAvailableCurrencies() async {
    try {
      final currencyBox =
          await hive.openBox<CurrencyModel>(DBConstants.currencyDbName);
      final currencies = currencyBox.values.toList();

      if (currencies.isEmpty) {
        await setDefaultCurrencies();
        return currencyBox.values.toList();
      }

      return currencies;
    } catch (e) {
      log(e.toString(), name: "Get available currencies exception");
      throw DatabaseFailure(
          message: "Failed to get available currencies: ${e.toString()}");
    }
  }

  @override
  Future<void> setDefaultCurrencies() async {
    try {
      final currencyBox =
          await hive.openBox<CurrencyModel>(DBConstants.currencyDbName);

      if (currencyBox.values.isEmpty) {
        for (var currency in _defaultCurrencies) {
          await currencyBox.put(currency.code, currency);
        }
      }
    } catch (e) {
      log(e.toString(), name: "Set default currencies exception");
      throw DatabaseFailure(
          message: "Failed to set default currencies: ${e.toString()}");
    }
  }
}

// Default currencies with conversion rates relative to USD
final List<CurrencyModel> _defaultCurrencies = [
  CurrencyModel(
    code: 'USD',
    name: 'US Dollar',
    symbol: '\$',
    conversionRate: 1.0, // Base currency
  ),
  CurrencyModel(
    code: 'EUR',
    name: 'Euro',
    symbol: '€',
    conversionRate: 0.93, // Example rate
  ),
  CurrencyModel(
    code: 'GBP',
    name: 'British Pound',
    symbol: '£',
    conversionRate: 0.79, // Example rate
  ),
  CurrencyModel(
    code: 'JPY',
    name: 'Japanese Yen',
    symbol: '¥',
    conversionRate: 150.59, // Example rate
  ),
  CurrencyModel(
    code: 'INR',
    name: 'Indian Rupee',
    symbol: '₹',
    conversionRate: 83.50, // Example rate
  ),
  CurrencyModel(
    code: 'CNY',
    name: 'Chinese Yuan',
    symbol: '¥',
    conversionRate: 7.24, // Example rate
  ),
  CurrencyModel(
    code: 'CAD',
    name: 'Canadian Dollar',
    symbol: 'C\$',
    conversionRate: 1.38, // Example rate
  ),
  CurrencyModel(
    code: 'AUD',
    name: 'Australian Dollar',
    symbol: 'A\$',
    conversionRate: 1.53, // Example rate
  ),
];
