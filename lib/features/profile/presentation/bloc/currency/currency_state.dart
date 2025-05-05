import 'package:equatable/equatable.dart';
import 'package:money_track/features/profile/domain/entities/currency_entity.dart';

/// Base state for currency
abstract class CurrencyState extends Equatable {
  const CurrencyState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class CurrencyInitial extends CurrencyState {}

/// Loading state
class CurrencyLoading extends CurrencyState {}

/// State when currencies are loaded
class CurrenciesLoaded extends CurrencyState {
  final List<CurrencyEntity> currencies;
  final CurrencyEntity selectedCurrency;

  const CurrenciesLoaded({
    required this.currencies,
    required this.selectedCurrency,
  });

  @override
  List<Object?> get props => [currencies, selectedCurrency];
}

/// State when currency conversion is completed
class CurrencyConverted extends CurrencyState {
  final double convertedAmount;
  final String fromCurrencyCode;
  final String toCurrencyCode;

  const CurrencyConverted({
    required this.convertedAmount,
    required this.fromCurrencyCode,
    required this.toCurrencyCode,
  });

  @override
  List<Object?> get props => [convertedAmount, fromCurrencyCode, toCurrencyCode];
}

/// Error state
class CurrencyError extends CurrencyState {
  final String message;

  const CurrencyError({required this.message});

  @override
  List<Object?> get props => [message];
}
