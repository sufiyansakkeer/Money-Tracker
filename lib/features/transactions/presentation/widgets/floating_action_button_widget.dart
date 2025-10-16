import 'package:flutter/material.dart';
import 'package:money_track/core/constants/colors.dart';
import 'package:money_track/core/utils/navigation_extension.dart';
import 'package:money_track/features/transactions/presentation/pages/add_transaction/transaction_page.dart';
import 'package:money_track/features/transactions/presentation/pages/split_expense_page.dart';
import 'package:svg_flutter/svg.dart';

class FloatingActionButtonWidget extends StatelessWidget {
  final bool isExpanded;
  final Animation<Offset> firstIconAnimation;
  final Animation<Offset> secondIconAnimation;
  final Animation<Offset> thirdIconAnimation;
  final VoidCallback toggleIcons;

  const FloatingActionButtonWidget({
    required this.isExpanded,
    required this.firstIconAnimation,
    required this.secondIconAnimation,
    required this.thirdIconAnimation,
    required this.toggleIcons,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final themeColor = ColorConstants.getThemeColor(context);
    final expenseColor = ColorConstants.getExpenseColor(context);
    final incomeColor = ColorConstants.getIncomeColor(context);

    return SizedBox(
      height: 400, // Increased height to accommodate expanded buttons
      child: Padding(
        padding: const EdgeInsets.only(
            bottom: 0,
            right: 20), // Removed bottom padding as it's handled in HomePage
        child: Stack(
          alignment: Alignment.bottomRight,
          children: [
            // Expense button
            Positioned(
              bottom: 130, // Increased to position above the bottom nav bar
              right: 5,
              child: SlideTransition(
                position: firstIconAnimation,
                child: Visibility(
                  visible: isExpanded,
                  maintainState: true,
                  maintainAnimation: true,
                  maintainSize: false,
                  child: Material(
                    color: expenseColor,
                    elevation: 4,
                    shadowColor: expenseColor.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(50),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(50),
                      splashColor: Colors.white.withValues(alpha: 0.2),
                      highlightColor: Colors.white.withValues(alpha: 0.1),
                      onTap: () {
                        toggleIcons();
                        context.pushWithDownToUpTransition(
                          const TransactionPage(isExpense: true),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 10),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SvgPicture.asset(
                              "assets/svg/home/Expense_button_icon.svg",
                              height: 30,
                              width: 24,
                              // colorFilter: const ColorFilter.mode(
                              //   Colors.white,
                              //   BlendMode.srcIn,
                              // ),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              "Expense",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Income button
            Positioned(
              bottom: 210, // Increased to position above the expense button
              right: 5,
              child: SlideTransition(
                position: secondIconAnimation,
                child: Visibility(
                  visible: isExpanded,
                  maintainState: true,
                  maintainAnimation: true,
                  maintainSize: false,
                  child: Material(
                    color: incomeColor,
                    elevation: 4,
                    shadowColor: incomeColor.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(50),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(50),
                      splashColor: Colors.white.withValues(alpha: 0.2),
                      highlightColor: Colors.white.withValues(alpha: 0.1),
                      onTap: () {
                        toggleIcons();
                        context.pushWithDownToUpTransition(
                          const TransactionPage(isExpense: false),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 10),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SvgPicture.asset(
                              "assets/svg/home/Income_button_icon.svg",
                              height: 30,
                              width: 24,
                              // colorFilter: const ColorFilter.mode(
                              //   Colors.white,
                              //   BlendMode.srcIn,
                              // ),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              "Income",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Split Expense button
            Positioned(
              bottom: 290, // Increased to position above the income button
              right: 5,
              child: SlideTransition(
                position: thirdIconAnimation,
                child: Visibility(
                  visible: isExpanded,
                  maintainState: true,
                  maintainAnimation: true,
                  maintainSize: false,
                  child: Material(
                    color: themeColor,
                    elevation: 4,
                    shadowColor: themeColor.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(50),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(50),
                      splashColor: Colors.white.withValues(alpha: 0.2),
                      highlightColor: Colors.white.withValues(alpha: 0.1),
                      onTap: () {
                        toggleIcons();
                        context.pushWithDownToUpTransition(
                          const SplitExpensePage(),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 10),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.splitscreen,
                              color: Colors.white,
                            ),
                            SizedBox(width: 8),
                            Text(
                              "Split Expense",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Main FAB
            Positioned(
              bottom: 0,
              right: 0,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: themeColor.withValues(alpha: 0.4),
                      blurRadius: isExpanded ? 16 : 8,
                      offset: const Offset(0, 4),
                      spreadRadius: isExpanded ? 2 : 0,
                    ),
                  ],
                  shape: BoxShape.circle,
                ),
                child: TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0.0, end: 1.0),
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.elasticOut,
                  builder: (context, value, child) {
                    return Transform.scale(
                      scale: value,
                      child: child,
                    );
                  },
                  child: AnimatedRotation(
                    turns: isExpanded ? 0.125 : 0, // 45 degrees when expanded
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    child: Material(
                      color: themeColor,
                      elevation: 0, // We're using the custom shadow above
                      shape: const CircleBorder(),
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        splashColor: Colors.white.withValues(alpha: 0.3),
                        highlightColor: Colors.white.withValues(alpha: 0.1),
                        onTap: toggleIcons,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                themeColor,
                                themeColor.withValues(alpha: 0.8),
                              ],
                            ),
                          ),
                          child: Center(
                            child: Icon(
                              isExpanded ? Icons.close : Icons.add,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
