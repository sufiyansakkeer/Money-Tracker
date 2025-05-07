import 'dart:developer' show log;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:money_track/core/constants/colors.dart';
import 'package:money_track/core/utils/date_time_extension.dart';
import 'package:money_track/core/utils/navigation_extension.dart';
import 'package:money_track/core/utils/sized_box_extension.dart';
import 'package:money_track/core/widgets/custom_app_bar.dart';
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
                                return TransactionTile(
                                  categoryType: item.categoryType,
                                  categoryName: item.category.categoryName,
                                  time: item.date.isToday()
                                      ? item.date.to12HourFormat()
                                      : item.date.toDayMonthYearFormat(),
                                  description: item.notes ?? "",
                                  amount: item.amount,
                                  type: item.transactionType,
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

class EditAndDeleteBottomSheet extends StatefulWidget {
  const EditAndDeleteBottomSheet({
    super.key,
    required this.transactionEntity,
  });

  final TransactionEntity transactionEntity;

  @override
  State<EditAndDeleteBottomSheet> createState() =>
      _EditAndDeleteBottomSheetState();
}

class _EditAndDeleteBottomSheetState extends State<EditAndDeleteBottomSheet>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  int? _hoveredIndex;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutBack,
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = ColorConstants.getThemeColor(context);
    final expenseColor = ColorConstants.getExpenseColor(context);
    final textColor = ColorConstants.getTextColor(context);

    return SafeArea(
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          );
        },
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Transaction Options",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                widget.transactionEntity.category.categoryName,
                style: TextStyle(
                  fontSize: 14,
                  color: textColor.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildActionButton(
                    index: 0,
                    icon: Icons.edit_outlined,
                    label: "Edit",
                    color: themeColor,
                    onTap: () {
                      context.pop();
                      context.pushWithRightToLeftTransition(
                        TransactionPage(
                          isExpense: widget.transactionEntity.transactionType ==
                              TransactionType.expense,
                          transactionEntity: widget.transactionEntity,
                        ),
                      );
                    },
                  ),
                  _buildActionButton(
                    index: 1,
                    icon: Icons.delete_outline,
                    label: "Delete",
                    color: expenseColor,
                    onTap: () {
                      // Show confirmation dialog
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text("Delete Transaction"),
                          content: const Text(
                            "Are you sure you want to delete this transaction? This action cannot be undone.",
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text(
                                "Cancel",
                                style: TextStyle(color: textColor),
                              ),
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: expenseColor,
                                foregroundColor: Colors.white,
                              ),
                              onPressed: () {
                                Navigator.pop(context); // Close dialog
                                context.pop(); // Close bottom sheet

                                // Delete the transaction
                                context.read<TransactionBloc>().add(
                                      DeleteTransactionEvent(
                                        transactionId:
                                            widget.transactionEntity.id,
                                      ),
                                    );

                                // Refresh budgets when transaction is deleted
                                context.read<BudgetBloc>().add(
                                      const RefreshBudgetsOnTransactionChange(),
                                    );
                              },
                              child: const Text("Delete"),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required int index,
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    final isHovered = _hoveredIndex == index;

    return MouseRegion(
      onEnter: (_) => setState(() => _hoveredIndex = index),
      onExit: (_) => setState(() => _hoveredIndex = null),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 130,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          decoration: BoxDecoration(
            color: isHovered
                ? color.withValues(alpha: 0.15)
                : color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isHovered
                  ? color.withValues(alpha: 0.5)
                  : color.withValues(alpha: 0.2),
              width: 1,
            ),
            boxShadow: isHovered
                ? [
                    BoxShadow(
                      color: color.withValues(alpha: 0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: color,
                size: 28,
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color:
                      isHovered ? color : ColorConstants.getTextColor(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
