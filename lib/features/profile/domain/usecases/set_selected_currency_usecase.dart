import 'package:money_track/core/error/result.dart';
import 'package:money_track/core/use_cases/use_case.dart';
import 'package:money_track/features/profile/domain/repositories/currency_repository.dart';

/// Use case for setting the selected currency
class SetSelectedCurrencyUseCase implements UseCase<Result<void>, String> {
  final CurrencyRepository repository;

  SetSelectedCurrencyUseCase(this.repository);

  @override
  Future<Result<void>> call({String? params}) {
    if (params == null) {
      throw ArgumentError('Currency code cannot be null');
    }
    return repository.setSelectedCurrency(params);
  }
}
