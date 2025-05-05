import 'package:money_track/core/error/result.dart';
import 'package:money_track/core/use_cases/use_case.dart';
import 'package:money_track/features/profile/domain/entities/currency_entity.dart';
import 'package:money_track/features/profile/domain/repositories/currency_repository.dart';

/// Use case for getting the currently selected currency
class GetSelectedCurrencyUseCase implements UseCase<Result<CurrencyEntity>, NoParams> {
  final CurrencyRepository repository;

  GetSelectedCurrencyUseCase(this.repository);

  @override
  Future<Result<CurrencyEntity>> call({NoParams? params}) {
    return repository.getSelectedCurrency();
  }
}
