import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:money_track/core/constants/colors.dart';
import 'package:money_track/core/utils/currency_formatter.dart';
import 'package:money_track/core/utils/sized_box_extension.dart';
import 'package:money_track/core/utils/widget_extension.dart';
import 'package:money_track/features/transactions/presentation/bloc/total_transaction/total_transaction_cubit.dart';
import 'package:money_track/features/transactions/presentation/widgets/source_tile.dart';

class TotalAmountWidget extends StatelessWidget {
  const TotalAmountWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          "Account Balance",
          style: TextStyle(
            color: ColorConstants.getTextColor(context).withValues(alpha: 0.6),
          ),
        ),
        10.height(),
        BlocBuilder<TotalTransactionCubit, TotalTransactionState>(
          builder: (context, state) {
            if (state is TotalTransactionSuccess) {
              return Text(
                CurrencyFormatter.format(
                    context, state.totalIncome - state.totalExpense),
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 28,
                  color: ColorConstants.getTextColor(context),
                ),
              );
            } else {
              return Text(
                CurrencyFormatter.format(context, 0),
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 28,
                  color: ColorConstants.getTextColor(context),
                ),
              );
            }
          },
        ),
        20.height(),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            BlocBuilder<TotalTransactionCubit, TotalTransactionState>(
              builder: (context, state) {
                if (state is TotalTransactionSuccess) {
                  return SourceTile(
                    color: ColorConstants.getIncomeColor(context),
                    sourceName: "Income",
                    sourceData: state.totalIncome,
                    sourceIcon: "assets/svg/home/income_icon.svg",
                    padding: const EdgeInsets.fromLTRB(8, 16, 8, 8),
                  );
                } else {
                  return SourceTile(
                    color: ColorConstants.getIncomeColor(context),
                    sourceName: "Income",
                    sourceData: 0,
                    sourceIcon: "assets/svg/home/income_icon.svg",
                    padding: const EdgeInsets.fromLTRB(8, 16, 8, 8),
                  );
                }
              },
            ).expand(),
            10.width(),
            BlocBuilder<TotalTransactionCubit, TotalTransactionState>(
              builder: (context, state) {
                if (state is TotalTransactionSuccess) {
                  return SourceTile(
                    color: ColorConstants.getExpenseColor(context),
                    sourceName: "Expense",
                    sourceData: state.totalExpense,
                    sourceIcon: "assets/svg/home/expense_icon.svg",
                  );
                } else {
                  return SourceTile(
                    color: ColorConstants.getExpenseColor(context),
                    sourceName: "Expense",
                    sourceData: 0,
                    sourceIcon: "assets/svg/home/expense_icon.svg",
                  );
                }
              },
            ).expand(),
          ],
        ),
      ],
    );
  }
}
