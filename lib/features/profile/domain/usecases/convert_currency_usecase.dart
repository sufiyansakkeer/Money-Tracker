import 'package:money_track/core/error/result.dart';
import 'package:money_track/core/use_cases/use_case.dart';
import 'package:money_track/features/profile/domain/repositories/currency_repository.dart';

/// Parameters for currency conversion
class ConvertCurrencyParams {
  final double amount;
  final String fromCurrencyCode;
  final String toCurrencyCode;

  ConvertCurrencyParams({
    required this.amount,
    required this.fromCurrencyCode,
    required this.toCurrencyCode,
  });
}

/// Use case for converting currency
class ConvertCurrencyUseCase implements UseCase<Result<double>, ConvertCurrencyParams> {
  final CurrencyRepository repository;

  ConvertCurrencyUseCase(this.repository);

  @override
  Future<Result<double>> call({ConvertCurrencyParams? params}) {
    if (params == null) {
      throw ArgumentError('ConvertCurrencyParams cannot be null');
    }
    return repository.convertCurrency(
      amount: params.amount,
      fromCurrencyCode: params.fromCurrencyCode,
      toCurrencyCode: params.toCurrencyCode,
    );
  }
}
