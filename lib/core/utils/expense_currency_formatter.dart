import 'package:intl/intl.dart';

/// Utility class for formatting currency in expense splitting context
/// This is separate from the main CurrencyFormatter to avoid BuildContext dependencies
class ExpenseCurrencyFormatter {
  static final Map<String, String> _currencySymbols = {
    'USD': '\$',
    'EUR': '€',
    'GBP': '£',
    'JPY': '¥',
    'CAD': 'C\$',
    'AUD': 'A\$',
    'CHF': 'CHF',
    'CNY': '¥',
    'INR': '₹',
    'KRW': '₩',
    'SGD': 'S\$',
    'HKD': 'HK\$',
    'NOK': 'kr',
    'SEK': 'kr',
    'DKK': 'kr',
    'PLN': 'zł',
    'CZK': 'Kč',
    'HUF': 'Ft',
    'RUB': '₽',
    'BRL': 'R\$',
  };

  static final Map<String, NumberFormat> _formatters = {};

  /// Format amount with currency symbol
  static String format(double amount, String currency) {
    final formatter = _getFormatter(currency);
    return formatter.format(amount);
  }

  /// Get currency symbol for a currency code
  static String getCurrencySymbol(String currency) {
    return _currencySymbols[currency] ?? currency;
  }

  /// Format amount without currency symbol
  static String formatAmount(double amount, {int decimalPlaces = 2}) {
    return amount.toStringAsFixed(decimalPlaces);
  }

  /// Parse formatted currency string to double
  static double? parseAmount(String formattedAmount) {
    // Remove currency symbols and spaces
    String cleanAmount = formattedAmount;
    for (String symbol in _currencySymbols.values) {
      cleanAmount = cleanAmount.replaceAll(symbol, '');
    }
    cleanAmount = cleanAmount.replaceAll(',', '').trim();
    return double.tryParse(cleanAmount);
  }

  /// Get formatter for specific currency
  static NumberFormat _getFormatter(String currency) {
    if (_formatters.containsKey(currency)) {
      return _formatters[currency]!;
    }

    NumberFormat formatter;
    try {
      formatter = NumberFormat.currency(
        symbol: getCurrencySymbol(currency),
        decimalDigits: _getDecimalDigits(currency),
      );
    } catch (e) {
      // Fallback to simple currency format
      formatter = NumberFormat.currency(
        symbol: getCurrencySymbol(currency),
        decimalDigits: 2,
      );
    }

    _formatters[currency] = formatter;
    return formatter;
  }

  /// Get decimal digits for currency
  static int _getDecimalDigits(String currency) {
    switch (currency) {
      case 'JPY':
      case 'KRW':
        return 0;
      default:
        return 2;
    }
  }

  /// Format amount for display in lists (shorter format)
  static String formatCompact(double amount, String currency) {
    if (amount.abs() >= 1000000) {
      return '${getCurrencySymbol(currency)}${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount.abs() >= 1000) {
      return '${getCurrencySymbol(currency)}${(amount / 1000).toStringAsFixed(1)}K';
    } else {
      return format(amount, currency);
    }
  }

  /// Check if currency is supported
  static bool isSupportedCurrency(String currency) {
    return _currencySymbols.containsKey(currency);
  }

  /// Get list of supported currencies
  static List<String> getSupportedCurrencies() {
    return _currencySymbols.keys.toList();
  }
}
