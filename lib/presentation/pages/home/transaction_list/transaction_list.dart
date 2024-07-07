import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:money_track/core/constants/colors.dart';
import 'package:money_track/helper/date_time_extension.dart';
import 'package:money_track/helper/sized_box_extension.dart';
import 'package:money_track/helper/widget_extension.dart';
import 'package:money_track/models/transaction_model/filter_model/filter_data.dart';
import 'package:money_track/presentation/bloc/transaction/total_transaction/total_transaction_cubit.dart';
import 'package:money_track/presentation/bloc/transaction/transaction_bloc.dart';
import 'package:money_track/presentation/pages/home/home_page.dart';
import 'package:money_track/presentation/pages/home/transaction_list/widget/filter_widget.dart';
import 'package:money_track/presentation/pages/home/widgets/empty_transaction_list.dart';
import 'package:money_track/presentation/pages/home/widgets/transaction_tile.dart';
import 'package:money_track/presentation/pages/settings/widget/custom_app_bar.dart';
import 'package:money_track/presentation/widgets/custom_inkwell.dart';
import 'package:svg_flutter/svg_flutter.dart';

import 'widget/date_filter_widget.dart';

class TransactionListPage extends StatefulWidget {
  const TransactionListPage({super.key});

  @override
  State<TransactionListPage> createState() => _TransactionListPageState();
}

class _TransactionListPageState extends State<TransactionListPage> {
  late FilterData filterData;

  @override
  void initState() {
    filterData = FilterData();
    super.initState();
  }

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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const DateFilterIcon(
                  dateType: 'Month',
                ),
                InkWell(
                    onTap: () {
                      showModalBottomSheet(
                        showDragHandle: true,
                        context: context,
                        builder: (context) => FilterWidget(
                          filterData: filterData,
                        ),
                      );
                    },
                    child: const SortIconWidget()),
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
                      ? const EmptyTransactionList()
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
                                  CustomInkWell(
                                    onLongPress: () {
                                      showModalBottomSheet(
                                        showDragHandle: true,
                                        context: context,
                                        builder: (context) =>
                                            EditAndDeleteBottomSheet(
                                          transactionModel: item,
                                        ),
                                      );
                                    },
                                    child: TransactionTile(
                                      categoryType: item.categoryType,
                                      categoryName:
                                          item.categoryModel.categoryName,
                                      time: item.date.to12HourFormat(),
                                      description: item.notes ?? "",
                                      amount: item.amount,
                                      type: item.transactionType,
                                    ),
                                  ),
                                ],
                              );
                            } else {
                              return CustomInkWell(
                                onLongPress: () {
                                  showModalBottomSheet(
                                    showDragHandle: true,
                                    context: context,
                                    builder: (context) =>
                                        EditAndDeleteBottomSheet(
                                      transactionModel: item,
                                    ),
                                  );
                                },
                                child: TransactionTile(
                                  categoryType: item.categoryType,
                                  categoryName: item.categoryModel.categoryName,
                                  time: item.date.to12HourFormat(),
                                  description: item.notes ?? "",
                                  amount: item.amount,
                                  type: item.transactionType,
                                ),
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
