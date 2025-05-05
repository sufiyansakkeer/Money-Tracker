import 'package:flutter/material.dart';
import 'package:money_track/core/constants/colors.dart';
import 'package:money_track/core/utils/sized_box_extension.dart';
import 'package:svg_flutter/svg.dart';

class ProfileTile extends StatelessWidget {
  const ProfileTile({
    super.key,
    required this.title,
    required this.subtitle,
    this.onPressed,
    this.icon,
  });
  final String title;
  final String subtitle;
  final void Function()? onPressed;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 10,
          horizontal: 20,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                if (icon != null)
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: ColorConstants.getSecondaryColor(context),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      icon,
                      color: ColorConstants.getThemeColor(context),
                      size: 20,
                    ),
                  ),
                if (icon != null) 12.width(),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: ColorConstants.getTextColor(context),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Text(
                  subtitle,
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: ColorConstants.getTextColor(context)
                          .withValues(alpha: 0.6)),
                ),
                10.width(),
                if (title != "")
                  SvgPicture.asset(
                    "assets/svg/common/arrow_right_rounded.svg",
                    colorFilter: ColorFilter.mode(
                        ColorConstants.getThemeColor(context), BlendMode.srcIn),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
