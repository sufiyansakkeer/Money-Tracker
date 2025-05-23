import 'dart:developer' show log;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:money_track/core/constants/colors.dart';
import 'package:money_track/core/utils/date_time_extension.dart';
import 'package:money_track/core/utils/navigation_extension.dart';
import 'package:money_track/core/utils/sized_box_extension.dart';
import 'package:money_track/core/widgets/custom_app_bar.dart';
import 'package:money_track/core/widgets/custom_inkwell.dart';
import 'package:money_track/domain/entities/category_entity.dart';
import 'package:money_track/domain/entities/transaction_entity.dart';
import 'package:money_track/features/budget/presentation/bloc/budget_bloc.dart';
import 'package:money_track/features/transactions/domain/entities/filter_data.dart';
import 'package:money_track/features/transactions/presentation/bloc/total_transaction/total_transaction_cubit.dart';
import 'package:money_track/features/transactions/presentation/bloc/transaction_bloc.dart';
import 'package:money_track/features/transactions/presentation/pages/add_transaction/transaction_page.dart';
import 'package:money_track/features/transactions/presentation/pages/transaction_list/widgets/date_filter_widget.dart';
import 'package:money_track/features/transactions/presentation/pages/transaction_list/widgets/filter_widget.dart';
import 'package:money_track/features/transactions/presentation/widgets/empty_transaction_list.dart';
import 'package:money_track/features/transactions/presentation/widgets/transaction_tile.dart';

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

    // Load transactions when page initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TransactionBloc>().add(GetAllTransactionsEvent());
    });
  }

  // Method to apply filters
  void _applyFilters() {
    log('Applying filters: ${filterData.dateFilterType}, Start: ${filterData.startDate}, End: ${filterData.endDate}');

    // If no filter type is set but dates are set, set to custom
    if (filterData.dateFilterType == null &&
        (filterData.startDate != null || filterData.endDate != null)) {
      filterData.dateFilterType = DateFilterType.custom;
    }

    context.read<TransactionBloc>().add(
          FilterTransactionEvent(filterData: filterData),
        );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        context.read<TransactionBloc>().add(GetAllTransactionsEvent());
      },
      child: Scaffold(
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
                  DateFilterIcon(
                    dateType: 'Month',
                    filterData: filterData,
                    onFilterChanged: () {
                      // Use the _applyFilters method to refresh the UI
                      _applyFilters();
                      // Force UI update to reflect the new filter text
                      setState(() {});
                    },
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
                    child: const SortIconWidget(),
                  ),
                ],
              ),
              30.height(),
              BlocConsumer<TransactionBloc, TransactionState>(
                listener: (context, state) {
                  if (state is TransactionLoaded) {
                    // Update total amounts
                    context.read<TotalTransactionCubit>().getTotalAmount();

                    // Refresh budgets when transactions change
                    context
                        .read<BudgetBloc>()
                        .add(const RefreshBudgetsOnTransactionChange());
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
                        : Expanded(
                            child: ListView.separated(
                              separatorBuilder: (context, index) => 10.height(),
                              primary: false,
                              shrinkWrap: true,
                              itemCount: state.transactionList.length,
                              itemBuilder: (_, index) {
                                var item = state.transactionList[index];
                                return CustomInkWell(
                                  onLongPress: () {
                                    showModalBottomSheet(
                                      showDragHandle: true,
                                      context: context,
                                      builder: (context) =>
                                          EditAndDeleteBottomSheet(
                                        transactionEntity: item,
                                      ),
                                    );
                                  },
                                  child: TransactionTile(
                                    categoryType: item.categoryType,
                                    categoryName: item.category.categoryName,
                                    time: item.date.isToday()
                                        ? item.date.to12HourFormat()
                                        : item.date.toDayMonthYearFormat(),
                                    description: item.notes ?? "",
                                    amount: item.amount,
                                    type: item.transactionType,
                                  ),
                                );
                              },
                            ),
                          );
                  } else {
                    return const Center(
                      child: Text("Something went wrong. Please try again"),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class EditAndDeleteBottomSheet extends StatelessWidget {
  const EditAndDeleteBottomSheet({
    super.key,
    required this.transactionEntity,
  });
  final TransactionEntity transactionEntity;
  @override
  Widget build(BuildContext context) {
    final themeColor = ColorConstants.getThemeColor(context);
    final expenseColor = ColorConstants.getExpenseColor(context);

    return SafeArea(
      child: SizedBox(
        width: 800,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 10,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              InkWell(
                onTap: () {
                  context.pop();
                  context.pushWithRightToLeftTransition(
                    TransactionPage(
                      isExpense: transactionEntity.transactionType ==
                          TransactionType.expense,
                      transactionEntity: transactionEntity,
                    ),
                  );
                },
                child: Container(
                  width: 100,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: themeColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.edit,
                        color: themeColor,
                      ),
                      5.height(),
                      Text(
                        "Edit",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: ColorConstants.getTextColor(context),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              20.width(),
              InkWell(
                onTap: () {
                  context.pop();
                  // Delete the transaction
                  context.read<TransactionBloc>().add(
                        DeleteTransactionEvent(
                          transactionId: transactionEntity.id,
                        ),
                      );

                  // Refresh budgets when transaction is deleted
                  context.read<BudgetBloc>().add(
                        const RefreshBudgetsOnTransactionChange(),
                      );
                },
                child: Container(
                  width: 100,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: expenseColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.delete,
                        color: expenseColor,
                      ),
                      5.height(),
                      Text(
                        "Delete",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: ColorConstants.getTextColor(context),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
