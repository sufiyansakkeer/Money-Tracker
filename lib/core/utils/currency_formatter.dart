import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:money_track/features/profile/domain/entities/currency_entity.dart';
import 'package:money_track/features/profile/presentation/bloc/currency/currency_cubit.dart';
import 'package:money_track/features/profile/presentation/bloc/currency/currency_state.dart';

/// Utility class for currency formatting
class CurrencyFormatter {
  /// Format an amount using the selected currency
  static String format(BuildContext context, double amount, {bool showSign = false, bool isExpense = false}) {
    final state = context.watch<CurrencyCubit>().state;
    
    if (state is CurrenciesLoaded) {
      final currency = state.selectedCurrency;
      final formatter = NumberFormat.currency(
        symbol: currency.symbol,
        decimalDigits: 2,
      );
      
      if (showSign) {
        final sign = isExpense ? '-' : '+';
        return '$sign ${formatter.format(amount)}';
      }
      
      return formatter.format(amount);
    }
    
    // Fallback to a default format if currency is not loaded
    return '₹${amount.toStringAsFixed(2)}';
  }
  
  /// Get the selected currency entity
  static CurrencyEntity? getSelectedCurrency(BuildContext context) {
    final state = context.read<CurrencyCubit>().state;
    
    if (state is CurrenciesLoaded) {
      return state.selectedCurrency;
    }
    
    return null;
  }
  
  /// Get the currency symbol
  static String getCurrencySymbol(BuildContext context) {
    final currency = getSelectedCurrency(context);
    return currency?.symbol ?? '₹';
  }
}
