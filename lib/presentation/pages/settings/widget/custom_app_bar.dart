import 'package:flutter/material.dart';
import 'package:money_track/helper/navigation_extension.dart';
import 'package:svg_flutter/svg_flutter.dart';

PreferredSize customAppBar(BuildContext context,
    {required String title, Color? color}) {
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
                    color != null
                        ? "assets/svg/common/arrow_left_white.svg"
                        : "assets/svg/common/arrow_left.svg",
                    height: 20,
                    // width: 20,
                  ),
                ),
                const Spacer(),
                Center(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: color != null ? Colors.white : null,
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
