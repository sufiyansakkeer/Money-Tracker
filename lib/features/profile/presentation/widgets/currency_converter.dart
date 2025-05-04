import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:money_track/core/constants/colors.dart';
import 'package:money_track/core/constants/style_constants.dart';
import 'package:money_track/features/profile/domain/entities/currency_entity.dart';
import 'package:money_track/features/profile/presentation/bloc/currency/currency_cubit.dart';
import 'package:money_track/features/profile/presentation/bloc/currency/currency_state.dart';

class CurrencyConverter extends StatefulWidget {
  final List<CurrencyEntity> currencies;
  final CurrencyEntity selectedCurrency;

  const CurrencyConverter({
    super.key,
    required this.currencies,
    required this.selectedCurrency,
  });

  @override
  State<CurrencyConverter> createState() => _CurrencyConverterState();
}

class _CurrencyConverterState extends State<CurrencyConverter> {
  late CurrencyEntity fromCurrency;
  late CurrencyEntity toCurrency;
  final TextEditingController amountController = TextEditingController();
  double? convertedAmount;
  bool isConverting = false;

  @override
  void initState() {
    super.initState();
    fromCurrency = widget.selectedCurrency;
    // Set toCurrency to a different currency than fromCurrency if possible
    if (widget.currencies.length > 1) {
      toCurrency = widget.currencies.firstWhere(
        (currency) => currency.code != fromCurrency.code,
        orElse: () => widget.currencies.first,
      );
    } else {
      toCurrency = widget.currencies.first;
    }
    amountController.text = '1.00';
  }

  @override
  void dispose() {
    amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Currency Converter',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: amountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: 'Amount',
              border: StyleConstants.textFormFieldBorder(),
              prefixIcon: const Icon(Icons.attach_money),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildCurrencyDropdown(
                  label: 'From',
                  value: fromCurrency,
                  onChanged: (CurrencyEntity? value) {
                    if (value != null) {
                      setState(() {
                        fromCurrency = value;
                        convertedAmount = null;
                      });
                    }
                  },
                ),
              ),
              IconButton(
                icon: const Icon(Icons.swap_horiz),
                onPressed: () {
                  setState(() {
                    final temp = fromCurrency;
                    fromCurrency = toCurrency;
                    toCurrency = temp;
                    convertedAmount = null;
                  });
                },
              ),
              Expanded(
                child: _buildCurrencyDropdown(
                  label: 'To',
                  value: toCurrency,
                  onChanged: (CurrencyEntity? value) {
                    if (value != null) {
                      setState(() {
                        toCurrency = value;
                        convertedAmount = null;
                      });
                    }
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: StyleConstants.elevatedButtonStyle(),
              onPressed: isConverting ? null : _convertCurrency,
              child: Text(
                isConverting ? 'Converting...' : 'Convert',
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ),
          const SizedBox(height: 16),
          BlocListener<CurrencyCubit, CurrencyState>(
            listener: (context, state) {
              if (state is CurrencyConverted) {
                setState(() {
                  convertedAmount = state.convertedAmount;
                  isConverting = false;
                });
              } else if (state is CurrencyError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.message)),
                );
                setState(() {
                  isConverting = false;
                });
              }
            },
            child: convertedAmount != null
                ? _buildConversionResult()
                : const SizedBox.shrink(),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildCurrencyDropdown({
    required String label,
    required CurrencyEntity value,
    required ValueChanged<CurrencyEntity?> onChanged,
  }) {
    return DropdownButtonFormField<CurrencyEntity>(
      decoration: InputDecoration(
        labelText: label,
        border: StyleConstants.textFormFieldBorder(),
      ),
      value: value,
      items: widget.currencies.map((currency) {
        return DropdownMenuItem<CurrencyEntity>(
          value: currency,
          child: Text('${currency.code} (${currency.symbol})'),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildConversionResult() {
    final formatter = NumberFormat.currency(
      symbol: toCurrency.symbol,
      decimalDigits: 2,
    );
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ColorConstants.secondaryColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Conversion Result:',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: ColorConstants.themeColor,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${amountController.text} ${fromCurrency.code}',
                style: const TextStyle(fontSize: 16),
              ),
              const Icon(Icons.arrow_forward),
              Text(
                formatter.format(convertedAmount),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Exchange Rate: 1 ${fromCurrency.code} = ${(toCurrency.conversionRate / fromCurrency.conversionRate).toStringAsFixed(4)} ${toCurrency.code}',
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  void _convertCurrency() {
    final amount = double.tryParse(amountController.text);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid amount')),
      );
      return;
    }

    setState(() {
      isConverting = true;
    });

    context.read<CurrencyCubit>().convertCurrency(
          amount: amount,
          fromCurrencyCode: fromCurrency.code,
          toCurrencyCode: toCurrency.code,
        );
  }
}
