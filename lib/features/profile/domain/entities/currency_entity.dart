import 'package:equatable/equatable.dart';

/// Entity class for currency
class CurrencyEntity extends Equatable {
  final String code;
  final String name;
  final String symbol;
  final double conversionRate; // Rate relative to a base currency (e.g., USD)

  const CurrencyEntity({
    required this.code,
    required this.name,
    required this.symbol,
    required this.conversionRate,
  });

  @override
  List<Object?> get props => [code, name, symbol, conversionRate];

  // Create a copy with updated values
  CurrencyEntity copyWith({
    String? code,
    String? name,
    String? symbol,
    double? conversionRate,
  }) {
    return CurrencyEntity(
      code: code ?? this.code,
      name: name ?? this.name,
      symbol: symbol ?? this.symbol,
      conversionRate: conversionRate ?? this.conversionRate,
    );
  }
}
