/// Multi-currency support utility for expense splitting
class CurrencyConverter {
  // In a real app, these would come from an API like exchangerate-api.com
  static const Map<String, double> _exchangeRates = {
    'USD': 1.0, // Base currency
    'EUR': 0.85,
    'GBP': 0.73,
    'JPY': 110.0,
    'CAD': 1.25,
    'AUD': 1.35,
    'CHF': 0.92,
    'CNY': 6.45,
    'INR': 74.5,
    'BRL': 5.2,
    'MXN': 20.1,
    'KRW': 1180.0,
    'SGD': 1.35,
    'HKD': 7.8,
    'NOK': 8.6,
    'SEK': 8.9,
    'DKK': 6.3,
    'PLN': 3.9,
    'CZK': 21.5,
    'HUF': 295.0,
  };

  static const List<String> _supportedCurrencies = [
    'USD', 'EUR', 'GBP', 'JPY', 'CAD', 'AUD', 'CHF', 'CNY', 'INR', 'BRL',
    'MXN', 'KRW', 'SGD', 'HKD', 'NOK', 'SEK', 'DKK', 'PLN', 'CZK', 'HUF',
  ];

  static const Map<String, String> _currencySymbols = {
    'USD': '\$',
    'EUR': '€',
    'GBP': '£',
    'JPY': '¥',
    'CAD': 'C\$',
    'AUD': 'A\$',
    'CHF': 'CHF',
    'CNY': '¥',
    'INR': '₹',
    'BRL': 'R\$',
    'MXN': '\$',
    'KRW': '₩',
    'SGD': 'S\$',
    'HKD': 'HK\$',
    'NOK': 'kr',
    'SEK': 'kr',
    'DKK': 'kr',
    'PLN': 'zł',
    'CZK': 'Kč',
    'HUF': 'Ft',
  };

  static const Map<String, String> _currencyNames = {
    'USD': 'US Dollar',
    'EUR': 'Euro',
    'GBP': 'British Pound',
    'JPY': 'Japanese Yen',
    'CAD': 'Canadian Dollar',
    'AUD': 'Australian Dollar',
    'CHF': 'Swiss Franc',
    'CNY': 'Chinese Yuan',
    'INR': 'Indian Rupee',
    'BRL': 'Brazilian Real',
    'MXN': 'Mexican Peso',
    'KRW': 'South Korean Won',
    'SGD': 'Singapore Dollar',
    'HKD': 'Hong Kong Dollar',
    'NOK': 'Norwegian Krone',
    'SEK': 'Swedish Krona',
    'DKK': 'Danish Krone',
    'PLN': 'Polish Złoty',
    'CZK': 'Czech Koruna',
    'HUF': 'Hungarian Forint',
  };

  /// Convert amount from one currency to another
  static double convert({
    required double amount,
    required String fromCurrency,
    required String toCurrency,
  }) {
    if (fromCurrency == toCurrency) return amount;
    
    final fromRate = _exchangeRates[fromCurrency];
    final toRate = _exchangeRates[toCurrency];
    
    if (fromRate == null || toRate == null) {
      throw ArgumentError('Unsupported currency: ${fromRate == null ? fromCurrency : toCurrency}');
    }
    
    // Convert to USD first, then to target currency
    final usdAmount = amount / fromRate;
    return usdAmount * toRate;
  }

  /// Get list of supported currencies
  static List<String> getSupportedCurrencies() {
    return List.from(_supportedCurrencies);
  }

  /// Get currency symbol
  static String getCurrencySymbol(String currency) {
    return _currencySymbols[currency] ?? currency;
  }

  /// Get currency name
  static String getCurrencyName(String currency) {
    return _currencyNames[currency] ?? currency;
  }

  /// Check if currency is supported
  static bool isCurrencySupported(String currency) {
    return _supportedCurrencies.contains(currency);
  }

  /// Format amount with currency symbol
  static String formatAmount(double amount, String currency, {int decimals = 2}) {
    final symbol = getCurrencySymbol(currency);
    final formattedAmount = amount.toStringAsFixed(decimals);
    
    // For some currencies, symbol goes after the amount
    if (['SEK', 'NOK', 'DKK', 'PLN', 'CZK', 'HUF'].contains(currency)) {
      return '$formattedAmount $symbol';
    }
    
    return '$symbol$formattedAmount';
  }

  /// Get exchange rate between two currencies
  static double getExchangeRate(String fromCurrency, String toCurrency) {
    if (fromCurrency == toCurrency) return 1.0;
    
    final fromRate = _exchangeRates[fromCurrency];
    final toRate = _exchangeRates[toCurrency];
    
    if (fromRate == null || toRate == null) {
      throw ArgumentError('Unsupported currency: ${fromRate == null ? fromCurrency : toCurrency}');
    }
    
    return toRate / fromRate;
  }

  /// Convert multiple amounts to a common currency
  static Map<String, double> convertMultiple({
    required Map<String, double> amounts, // currency -> amount
    required String targetCurrency,
  }) {
    final convertedAmounts = <String, double>{};
    
    for (final entry in amounts.entries) {
      convertedAmounts[entry.key] = convert(
        amount: entry.value,
        fromCurrency: entry.key,
        toCurrency: targetCurrency,
      );
    }
    
    return convertedAmounts;
  }

  /// Get total amount in target currency from mixed currency amounts
  static double getTotalInCurrency({
    required Map<String, double> amounts, // currency -> amount
    required String targetCurrency,
  }) {
    double total = 0.0;
    
    for (final entry in amounts.entries) {
      total += convert(
        amount: entry.value,
        fromCurrency: entry.key,
        toCurrency: targetCurrency,
      );
    }
    
    return total;
  }

  /// Get currency info
  static CurrencyInfo getCurrencyInfo(String currency) {
    return CurrencyInfo(
      code: currency,
      name: getCurrencyName(currency),
      symbol: getCurrencySymbol(currency),
      exchangeRate: _exchangeRates[currency] ?? 1.0,
    );
  }

  /// Get all currency info
  static List<CurrencyInfo> getAllCurrencyInfo() {
    return _supportedCurrencies
        .map((currency) => getCurrencyInfo(currency))
        .toList();
  }

  /// Update exchange rates (in a real app, this would fetch from an API)
  static void updateExchangeRates(Map<String, double> newRates) {
    // In a real implementation, this would update the rates
    // For now, we'll keep the static rates
    // _exchangeRates.addAll(newRates);
  }

  /// Get popular currencies (most commonly used)
  static List<String> getPopularCurrencies() {
    return ['USD', 'EUR', 'GBP', 'JPY', 'CAD', 'AUD', 'CHF', 'CNY', 'INR'];
  }
}

/// Currency information model
class CurrencyInfo {
  final String code;
  final String name;
  final String symbol;
  final double exchangeRate;

  CurrencyInfo({
    required this.code,
    required this.name,
    required this.symbol,
    required this.exchangeRate,
  });

  @override
  String toString() => '$name ($code)';
}
