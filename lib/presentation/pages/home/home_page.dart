import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:money_track/core/constants/colors.dart';
import 'package:money_track/helper/date_time_extension.dart';
import 'package:money_track/helper/navigation_extension.dart';
import 'package:money_track/helper/sized_box_extension.dart';
import 'package:money_track/presentation/bloc/transaction/transaction_bloc.dart';
import 'package:money_track/presentation/pages/home/transaction/transaction_page.dart';
import 'package:money_track/presentation/pages/home/widgets/transaction_tile.dart';
import 'package:money_track/presentation/widgets/custom_inkwell.dart';
import 'package:svg_flutter/svg_flutter.dart';
import 'widgets/total_amount_widget.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  AnimationController? _animationController;
  Animation<Offset>? _firstIconAnimation;
  Animation<Offset>? _secondIconAnimation;

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
        parent: _animationController!,
        curve: Curves.easeOut,
      ),
    );

    _secondIconAnimation = Tween<Offset>(
      begin: const Offset(0, 2.5),
      end: const Offset(0, -0.5),
    ).animate(
      CurvedAnimation(
        parent: _animationController!,
        curve: Curves.easeOut,
      ),
    );
  }

  void _toggleIcons() {
    if (_isExpanded) {
      _animationController?.reverse();
    } else {
      _animationController?.forward();
    }
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  @override
  void dispose() {
    _animationController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Stack(
          children: [
            Container(
              height: MediaQuery.sizeOf(context).height,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment(0.9, 0.1),
                  colors: [
                    Color(0xFFFFF6E5),
                    Colors.white,
                  ],
                ),
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    20.height(),
                    const TotalAmountWidget(),
                    20.height(),
                    Row(
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
                          onPressed: () {},
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
                        )
                      ],
                    ),
                    20.height(),
                    BlocBuilder<TransactionBloc, TransactionState>(
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
                                  separatorBuilder: (context, index) =>
                                      10.height(),
                                  primary: false,
                                  shrinkWrap: true,
                                  itemBuilder: (context, index) =>
                                      TransactionTile(
                                    categoryType: state
                                        .transactionList[index].categoryType,
                                    categoryName: state.transactionList[index]
                                        .categoryModel.categoryName,
                                    time: state.transactionList[index].date
                                        .to12HourFormat(),
                                    description:
                                        state.transactionList[index].notes ??
                                            "",
                                    amount: state.transactionList[index].amount,
                                    type: state
                                        .transactionList[index].transactionType,
                                  ),
                                  itemCount: state.transactionList.length,
                                );
                        } else {
                          return const Center(
                              child: Text(
                                  "Something Went wrong. Please try again"));
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
            if (_isExpanded) ...[
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      ColorConstants.themeColor.withOpacity(0.3),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ],
          ],
        ),
        floatingActionButton: SizedBox(
          height: 300,
          child: Padding(
            padding: const EdgeInsets.only(
              bottom: 100,
              right: 20,
            ),
            child: Stack(
              alignment: Alignment.bottomRight,
              children: [
                Positioned(
                  bottom: 80,
                  right: 5,
                  child: SlideTransition(
                    position: _firstIconAnimation!,
                    child: CustomInkWell(
                      onTap: () {
                        _toggleIcons();
                        context.pushWithDownToUpTransition(
                            const TransactionPage(isExpense: true));
                      },
                      child: SvgPicture.asset(
                          "assets/svg/home/Expense_button_icon.svg"),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 140,
                  right: 5,
                  child: SlideTransition(
                    position: _secondIconAnimation!,
                    child: CustomInkWell(
                      onTap: () {
                        _toggleIcons();
                        context.pushWithDownToUpTransition(
                            const TransactionPage(isExpense: false));
                      },
                      child: SvgPicture.asset(
                          "assets/svg/home/Income_button_icon.svg"),
                    ),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: ColorConstants.secondaryColor,
                      padding: const EdgeInsets.all(20)),
                  child: Icon(_isExpanded ? Icons.close : Icons.add),
                  onPressed: () {
                    _toggleIcons();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
