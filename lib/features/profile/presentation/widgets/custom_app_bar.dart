import 'package:flutter/material.dart';
import 'package:money_track/core/constants/colors.dart';
import 'package:money_track/core/utils/navigation_extension.dart';
import 'package:svg_flutter/svg.dart';

PreferredSize customAppBar(BuildContext context,
    {required String title, Color? color}) {
  final themeColor = ColorConstants.getThemeColor(context);
  final textColor =
      color != null ? Colors.white : ColorConstants.getTextColor(context);
  final isDark = Theme.of(context).brightness == Brightness.dark;

  return PreferredSize(
      preferredSize: const Size(double.infinity, 50),
      child: SafeArea(
        child: Container(
          color: color,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                InkWell(
                  onTap: () => context.pop(),
                  child: SvgPicture.asset(
                    color != null || isDark
                        ? "assets/svg/common/arrow_left_white.svg"
                        : "assets/svg/common/arrow_left.svg",
                    height: 20,
                    colorFilter: color == null && !isDark
                        ? ColorFilter.mode(themeColor, BlendMode.srcIn)
                        : null,
                  ),
                ),
                const Spacer(),
                Center(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const Spacer()
              ],
            ),
          ),
        ),
      ));
}
