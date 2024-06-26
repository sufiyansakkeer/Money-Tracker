import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:money_track/core/constants/colors.dart';
import 'package:money_track/helper/date_time_extension.dart';
import 'package:money_track/helper/sized_box_extension.dart';
import 'package:money_track/helper/widget_extension.dart';
import 'package:money_track/presentation/bloc/transaction/total_transaction/total_transaction_cubit.dart';
import 'package:money_track/presentation/bloc/transaction/transaction_bloc.dart';
import 'package:money_track/presentation/pages/home/widgets/transaction_tile.dart';
import 'package:money_track/presentation/pages/settings/widget/custom_app_bar.dart';
import 'package:svg_flutter/svg_flutter.dart';

class TransactionListPage extends StatelessWidget {
  const TransactionListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(context, title: "Transaction List"),
      body: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
        ),
        child: Column(
          children: [
            20.height(),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                DateFilterIcon(
                  dateType: 'Month',
                ),
                SortIconWidget(),
              ],
            ),
            30.height(),
            BlocConsumer<TransactionBloc, TransactionState>(
              listener: (context, state) {
                if (state is TransactionLoaded) {
                  context.read<TotalTransactionCubit>().getTotalAmount();
                }
              },
              builder: (context, state) {
                if (state is TransactionLoading) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                } else if (state is TransactionLoaded) {
                  return state.transactionList.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              100.height(),
                              const Text(
                                "No transaction found",
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.separated(
                          separatorBuilder: (context, index) => 10.height(),
                          primary: false,
                          shrinkWrap: true,
                          itemBuilder: (_, index) {
                            var item = state.transactionList[index];
                            DateTime date = item.date;
                            bool isSameDate = true;
                            if (index == 0) {
                              isSameDate = false;
                            } else {
                              isSameDate = date.compareDatesOnly(
                                  state.transactionList[index - 1].date);
                            }

                            if (index == 0 || (!isSameDate)) {
                              return Column(
                                children: [
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      item.date.isToday()
                                          ? "Today"
                                          : item.date.isYesterday()
                                              ? "Yesterday"
                                              : item.date
                                                  .toDayMonthYearFormat(),
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  10.height(),
                                  TransactionTile(
                                    categoryType: item.categoryType,
                                    categoryName:
                                        item.categoryModel.categoryName,
                                    time: item.date.to12HourFormat(),
                                    description: item.notes ?? "",
                                    amount: item.amount,
                                    type: item.transactionType,
                                  ),
                                ],
                              );
                            } else {
                              return TransactionTile(
                                categoryType: item.categoryType,
                                categoryName: item.categoryModel.categoryName,
                                time: item.date.to12HourFormat(),
                                description: item.notes ?? "",
                                amount: item.amount,
                                type: item.transactionType,
                              );
                            }
                          },
                          itemCount: state.transactionList.length,
                        );
                } else {
                  return const Center(
                      child: Text("Something Went wrong. Please try again"));
                }
              },
            ).expand(),
          ],
        ),
      ),
    );
  }
}

class SortIconWidget extends StatelessWidget {
  const SortIconWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border.all(
          color: ColorConstants.borderColor,
        ),
        borderRadius: BorderRadius.circular(
          10,
        ),
      ),
      child: SvgPicture.asset(
        "assets/svg/common/sort.svg",
      ),
    );
  }
}

class DateFilterIcon extends StatelessWidget {
  const DateFilterIcon({
    super.key,
    required this.dateType,
  });
  final String dateType;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        border: Border.all(
          color: ColorConstants.borderColor,
        ),
        borderRadius: BorderRadius.circular(
          30,
        ),
      ),
      child: Row(
        children: [
          SvgPicture.asset(
            "assets/svg/common/arrow_down_rounded.svg",
            colorFilter: ColorFilter.mode(
              ColorConstants.themeColor,
              BlendMode.srcIn,
            ),
          ),
          5.width(),
          Text(
            dateType,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
