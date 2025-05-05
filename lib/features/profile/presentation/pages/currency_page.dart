import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:money_track/core/constants/colors.dart';
import 'package:money_track/core/constants/style_constants.dart';
import 'package:money_track/features/profile/domain/entities/currency_entity.dart';
import 'package:money_track/features/profile/presentation/bloc/currency/currency_cubit.dart';
import 'package:money_track/features/profile/presentation/bloc/currency/currency_state.dart';
import 'package:money_track/features/profile/presentation/widgets/custom_app_bar.dart';
import 'package:money_track/features/profile/presentation/widgets/currency_converter.dart';

class CurrencyPage extends StatefulWidget {
  const CurrencyPage({super.key});

  @override
  State<CurrencyPage> createState() => _CurrencyPageState();
}

class _CurrencyPageState extends State<CurrencyPage> {
  @override
  void initState() {
    super.initState();
    // Load currencies when the page is opened
    context.read<CurrencyCubit>().loadCurrencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(context, title: "Currency"),
      body: BlocBuilder<CurrencyCubit, CurrencyState>(
        builder: (context, state) {
          if (state is CurrencyLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is CurrenciesLoaded) {
            return _buildCurrencyList(
                context, state.currencies, state.selectedCurrency);
          } else if (state is CurrencyError) {
            return Center(child: Text("Error: ${state.message}"));
          } else {
            return const Center(child: Text("Select a currency"));
          }
        },
      ),
    );
  }

  Widget _buildCurrencyList(
    BuildContext context,
    List<CurrencyEntity> currencies,
    CurrencyEntity selectedCurrency,
  ) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            "Selected Currency: ${selectedCurrency.name} (${selectedCurrency.symbol})",
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const Divider(),
        Expanded(
          child: ListView.separated(
            itemCount: currencies.length,
            separatorBuilder: (context, index) => const Divider(),
            itemBuilder: (context, index) {
              final currency = currencies[index];
              final isSelected = currency.code == selectedCurrency.code;

              return ListTile(
                title: Text(
                  currency.name,
                  style: TextStyle(
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                subtitle: Text("${currency.symbol} - ${currency.code}"),
                trailing: isSelected
                    ? Icon(Icons.check_circle,
                        color: ColorConstants.getThemeColor(context))
                    : null,
                onTap: () {
                  context
                      .read<CurrencyCubit>()
                      .setSelectedCurrency(currency.code);
                },
              );
            },
          ),
        ),
        const Divider(),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton(
            style: StyleConstants.elevatedButtonStyle(context: context),
            onPressed: () {
              _showCurrencyConverter(context, currencies, selectedCurrency);
            },
            child: const Text(
              "Currency Converter",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  void _showCurrencyConverter(
    BuildContext context,
    List<CurrencyEntity> currencies,
    CurrencyEntity selectedCurrency,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => CurrencyConverter(
        currencies: currencies,
        selectedCurrency: selectedCurrency,
      ),
    );
  }
}
