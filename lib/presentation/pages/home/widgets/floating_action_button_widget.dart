import 'package:flutter/material.dart';
import 'package:money_track/core/constants/colors.dart';
import 'package:money_track/helper/navigation_extension.dart';
import 'package:money_track/presentation/pages/home/add_transaction/transaction_page.dart';
import 'package:svg_flutter/svg_flutter.dart';

class FloatingActionButtonWidget extends StatelessWidget {
  final bool isExpanded;
  final Animation<Offset> firstIconAnimation;
  final Animation<Offset> secondIconAnimation;
  final VoidCallback toggleIcons;

  const FloatingActionButtonWidget({
    required this.isExpanded,
    required this.firstIconAnimation,
    required this.secondIconAnimation,
    required this.toggleIcons,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 100, right: 20),
        child: Stack(
          alignment: Alignment.bottomRight,
          children: [
            Positioned(
              bottom: 80,
              right: 5,
              child: SlideTransition(
                position: firstIconAnimation,
                child: InkWell(
                  borderRadius: BorderRadius.circular(50),
                  onTap: () {
                    toggleIcons();
                    context.pushWithDownToUpTransition(
                      const TransactionPage(isExpense: true),
                    );
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
                position: secondIconAnimation,
                child: InkWell(
                  borderRadius: BorderRadius.circular(50),
                  onTap: () {
                    toggleIcons();
                    context.pushWithDownToUpTransition(
                      const TransactionPage(isExpense: false),
                    );
                  },
                  child: Container(
                    decoration:
                        BoxDecoration(borderRadius: BorderRadius.circular(50)),
                    child: SvgPicture.asset(
                        "assets/svg/home/Income_button_icon.svg"),
                  ),
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorConstants.secondaryColor,
                padding: const EdgeInsets.all(20),
              ),
              onPressed: toggleIcons,
              child: Icon(isExpanded ? Icons.close : Icons.add),
            ),
          ],
        ),
      ),
    );
  }
}
