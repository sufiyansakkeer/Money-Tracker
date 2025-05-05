import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:money_track/core/error/result.dart';
import 'package:money_track/core/use_cases/use_case.dart';
import 'package:money_track/features/profile/domain/entities/currency_entity.dart';
import 'package:money_track/features/profile/domain/usecases/convert_currency_usecase.dart';
import 'package:money_track/features/profile/domain/usecases/get_available_currencies_usecase.dart';
import 'package:money_track/features/profile/domain/usecases/get_selected_currency_usecase.dart';
import 'package:money_track/features/profile/domain/usecases/set_selected_currency_usecase.dart';
import 'package:money_track/features/profile/presentation/bloc/currency/currency_state.dart';

class CurrencyCubit extends Cubit<CurrencyState> {
  final GetSelectedCurrencyUseCase getSelectedCurrencyUseCase;
  final SetSelectedCurrencyUseCase setSelectedCurrencyUseCase;
  final GetAvailableCurrenciesUseCase getAvailableCurrenciesUseCase;
  final ConvertCurrencyUseCase convertCurrencyUseCase;

  CurrencyCubit({
    required this.getSelectedCurrencyUseCase,
    required this.setSelectedCurrencyUseCase,
    required this.getAvailableCurrenciesUseCase,
    required this.convertCurrencyUseCase,
  }) : super(CurrencyInitial());

  /// Load currencies and the selected currency
  Future<void> loadCurrencies() async {
    emit(CurrencyLoading());

    try {
      final currenciesResult =
          await getAvailableCurrenciesUseCase(params: NoParams());
      final selectedCurrencyResult =
          await getSelectedCurrencyUseCase(params: NoParams());

      if (currenciesResult is Success<List<CurrencyEntity>> &&
          selectedCurrencyResult is Success<CurrencyEntity>) {
        final currencies = currenciesResult.data;
        final selectedCurrency = selectedCurrencyResult.data;

        emit(CurrenciesLoaded(
          currencies: currencies,
          selectedCurrency: selectedCurrency,
        ));
      } else {
        String errorMessage = 'Failed to load currencies';
        if (currenciesResult is Error<List<CurrencyEntity>>) {
          errorMessage = currenciesResult.failure.message;
        } else if (selectedCurrencyResult is Error<CurrencyEntity>) {
          errorMessage = selectedCurrencyResult.failure.message;
        }
        emit(CurrencyError(message: errorMessage));
      }
    } catch (e) {
      log(e.toString(), name: 'CurrencyCubit.loadCurrencies');
      emit(CurrencyError(message: e.toString()));
    }
  }

  /// Set the selected currency
  Future<void> setSelectedCurrency(String currencyCode) async {
    emit(CurrencyLoading());

    try {
      final result = await setSelectedCurrencyUseCase(params: currencyCode);

      if (result is Success) {
        // Reload currencies to reflect the change
        await loadCurrencies();
      } else if (result is Error<void>) {
        emit(CurrencyError(message: result.failure.message));
      }
    } catch (e) {
      log(e.toString(), name: 'CurrencyCubit.setSelectedCurrency');
      emit(CurrencyError(message: e.toString()));
    }
  }

  /// Convert an amount from one currency to another
  Future<void> convertCurrency({
    required double amount,
    required String fromCurrencyCode,
    required String toCurrencyCode,
  }) async {
    emit(CurrencyLoading());

    try {
      final params = ConvertCurrencyParams(
        amount: amount,
        fromCurrencyCode: fromCurrencyCode,
        toCurrencyCode: toCurrencyCode,
      );

      final result = await convertCurrencyUseCase(params: params);

      if (result is Success<double>) {
        emit(CurrencyConverted(
          convertedAmount: result.data,
          fromCurrencyCode: fromCurrencyCode,
          toCurrencyCode: toCurrencyCode,
        ));
      } else if (result is Error<double>) {
        emit(CurrencyError(message: result.failure.message));
      }
    } catch (e) {
      log(e.toString(), name: 'CurrencyCubit.convertCurrency');
      emit(CurrencyError(message: e.toString()));
    }
  }
}
