import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:money_track/core/constants/colors.dart';
import 'package:money_track/core/utils/date_time_extension.dart';
import 'package:money_track/core/utils/navigation_extension.dart';
import 'package:money_track/core/utils/sized_box_extension.dart';
import 'package:money_track/domain/entities/category_entity.dart';
import 'package:money_track/domain/entities/transaction_entity.dart';
import 'package:money_track/features/transactions/presentation/bloc/transaction_bloc.dart';
import 'package:money_track/features/transactions/presentation/bloc/total_transaction/total_transaction_cubit.dart';
import 'package:money_track/features/transactions/presentation/pages/add_transaction/transaction_page.dart';
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
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _firstIconAnimation = Tween<Offset>(
      begin: const Offset(0, 1.4),
      end: const Offset(0, -0.3),
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
      ),
    );

    _secondIconAnimation = Tween<Offset>(
      begin: const Offset(0, 2.5),
      end: const Offset(0, -0.5),
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
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
            if (_isExpanded) const OverlayWidget(),
          ],
        ),
        floatingActionButton: FloatingActionButtonWidget(
          isExpanded: _isExpanded,
          firstIconAnimation: _firstIconAnimation,
          secondIconAnimation: _secondIconAnimation,
          toggleIcons: _toggleIcons,
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
        const Text(
          "Recent transaction",
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
        ElevatedButton(
          onPressed: () {
            // Navigate to transaction list page
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: ColorConstants.secondaryColor,
            elevation: 0,
          ),
          child: Text(
            "See All",
            style: TextStyle(
              color: ColorConstants.themeColor,
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

class EditAndDeleteBottomSheet extends StatelessWidget {
  const EditAndDeleteBottomSheet({
    super.key,
    required this.transactionEntity,
  });
  final TransactionEntity transactionEntity;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
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
                  color:
                      ColorConstants.themeColor.withAlpha(102), // 0.4 opacity
                  borderRadius: BorderRadius.circular(
                    5,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.edit,
                      color: ColorConstants.themeColor,
                    ),
                    5.height(),
                    const Text(
                      "Edit",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            40.width(),
            InkWell(
              onTap: () {
                context.read<TransactionBloc>().add(
                      DeleteTransactionEvent(
                        transactionId: transactionEntity.id,
                      ),
                    );
                context.pop();
              },
              child: Container(
                width: 100,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color:
                      ColorConstants.expenseColor.withAlpha(102), // 0.4 opacity
                  borderRadius: BorderRadius.circular(
                    5,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.delete,
                      color: ColorConstants.expenseColor,
                    ),
                    5.height(),
                    const Text(
                      "Delete",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
