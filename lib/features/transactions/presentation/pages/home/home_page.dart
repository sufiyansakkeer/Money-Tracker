import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:money_track/core/constants/colors.dart';
import 'package:money_track/core/utils/date_time_extension.dart';
import 'package:money_track/core/utils/navigation_extension.dart';
import 'package:money_track/core/utils/sized_box_extension.dart';
import 'package:money_track/domain/entities/category_entity.dart';
import 'package:money_track/domain/entities/transaction_entity.dart';
import 'package:money_track/features/budget/presentation/bloc/budget_bloc.dart';
import 'package:money_track/features/transactions/presentation/bloc/transaction_bloc.dart';
import 'package:money_track/features/transactions/presentation/bloc/total_transaction/total_transaction_cubit.dart';
import 'package:money_track/features/transactions/presentation/pages/add_transaction/transaction_page.dart';
import 'package:money_track/features/transactions/presentation/pages/transaction_list/transaction_list_page.dart';
import 'package:money_track/features/transactions/presentation/widgets/background.dart';
import 'package:money_track/features/transactions/presentation/widgets/empty_transaction_list.dart';
import 'package:money_track/features/transactions/presentation/widgets/floating_action_button_widget.dart';
import 'package:money_track/features/transactions/presentation/widgets/overlay_widget.dart';
import 'package:money_track/features/transactions/presentation/widgets/total_amount_widget.dart';
import 'package:money_track/features/transactions/presentation/widgets/transaction_tile.dart';
import 'package:money_track/core/widgets/custom_inkwell.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _animationController;
  late Animation<Offset> _firstIconAnimation;
  late Animation<Offset> _secondIconAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _firstIconAnimation = Tween<Offset>(
      begin: const Offset(0, 2.0),
      end: const Offset(0, 0),
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutBack,
      ),
    );

    _secondIconAnimation = Tween<Offset>(
      begin: const Offset(0, 3.0),
      end: const Offset(0, 0),
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutBack,
      ),
    );
  }

  void _toggleIcons() {
    if (_isExpanded) {
      _animationController.reverse();
    } else {
      _animationController.forward();
    }
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Stack(
          children: [
            const Background(),
            const BodyContent(),
            if (_isExpanded)
              GestureDetector(
                onTap: _toggleIcons, // Close menu when tapping outside
                child: const OverlayWidget(),
              ),
          ],
        ),
        floatingActionButton: Padding(
          padding: const EdgeInsets.only(
              bottom: 100), // Adjusted padding to better align with nav bar
          child: FloatingActionButtonWidget(
            isExpanded: _isExpanded,
            firstIconAnimation: _firstIconAnimation,
            secondIconAnimation: _secondIconAnimation,
            toggleIcons: _toggleIcons,
          ),
        ),
      ),
    );
  }
}

class BodyContent extends StatelessWidget {
  const BodyContent({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          20.height(),
          const TotalAmountWidget(),
          20.height(),
          const TransactionHeader(),
          20.height(),
          const TransactionList(),
        ],
      ),
    );
  }
}

class TransactionHeader extends StatelessWidget {
  const TransactionHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "Recent transaction",
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 20,
            color: ColorConstants.getTextColor(context),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            context.pushWithRightToLeftTransition(
              const TransactionListPage(),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: ColorConstants.getSecondaryColor(context),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            elevation: 0,
          ),
          child: Text(
            "See All",
            style: TextStyle(
              color: ColorConstants.getThemeColor(context),
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class TransactionList extends StatelessWidget {
  const TransactionList({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TransactionBloc, TransactionState>(
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
              : FilledTransactionList(transactionList: state.transactionList);
        } else {
          return const Center(
            child: Text("Something went wrong. Please try again"),
          );
        }
      },
    );
  }
}

class FilledTransactionList extends StatelessWidget {
  final List<TransactionEntity> transactionList;

  const FilledTransactionList({required this.transactionList, super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      separatorBuilder: (context, index) => const SizedBox(height: 10),
      primary: false,
      shrinkWrap: true,
      itemCount: transactionList.length,
      itemBuilder: (_, index) {
        var item = transactionList[index];
        return CustomInkWell(
          onLongPress: () {
            showModalBottomSheet(
              showDragHandle: true,
              context: context,
              builder: (context) => EditAndDeleteBottomSheet(
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
