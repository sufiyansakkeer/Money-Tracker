import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:money_track/core/constants/colors.dart';
import 'package:money_track/helper/sized_box_extension.dart';
import 'package:money_track/helper/widget_extension.dart';
import 'package:money_track/presentation/bloc/transaction/total_transaction/total_transaction_cubit.dart';
import 'package:money_track/presentation/pages/home/widgets/source_tile.dart';

class TotalAmountWidget extends StatelessWidget {
  const TotalAmountWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          "Account Balance",
          style: TextStyle(
            color: Colors.grey,
          ),
        ),
        10.height(),
        BlocBuilder<TotalTransactionCubit, TotalTransactionState>(
          builder: (context, state) {
            if (state is TotalTransactionSuccess) {
              return Text(
                "${state.totalIncome - state.totalExpense}",
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 28,
                ),
              );
            } else {
              return const Text(
                "₹0",
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 28,
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
                    color: ColorConstants.incomeColor,
                    sourceName: "Income",
                    sourceData: state.totalIncome,
                    sourceIcon: "assets/svg/home/income_icon.svg",
                    padding: const EdgeInsets.fromLTRB(8, 16, 8, 8),
                  );
                } else {
                  return SourceTile(
                    color: ColorConstants.incomeColor,
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
                    color: ColorConstants.expenseColor,
                    sourceName: "Expense",
                    sourceData: state.totalExpense,
                    sourceIcon: "assets/svg/home/expense_icon.svg",
                  );
                } else {
                  return SourceTile(
                    color: ColorConstants.expenseColor,
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
