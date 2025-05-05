import 'package:flutter/material.dart';
import 'package:money_track/core/constants/colors.dart';

class Background extends StatelessWidget {
  const Background({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final themeColor = ColorConstants.getThemeColor(context);

    return Container(
      height: MediaQuery.of(context).size.height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: const Alignment(0.9, 0.1),
          colors: isDarkMode
              ? [
                  themeColor.withValues(alpha: 0.15),
                  Theme.of(context).scaffoldBackgroundColor,
                ]
              : [
                  const Color(0xFFFFF6E5),
                  Colors.white,
                ],
        ),
      ),
    );
  }
}
