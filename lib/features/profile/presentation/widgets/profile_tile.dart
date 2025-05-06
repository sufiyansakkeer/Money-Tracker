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
    // If title is empty, return an empty container (as a fallback)
    if (title.isEmpty) {
      return const SizedBox.shrink();
    }

    return InkWell(
      onTap: onPressed,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          vertical: 10,
          horizontal: 20,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Left side with icon and title
            Expanded(
              flex: 2,
              child: Row(
                mainAxisSize: MainAxisSize.min,
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
                  Flexible(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: ColorConstants.getTextColor(context),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),

            // Right side with subtitle and arrow
            Expanded(
              flex: 1,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Text(
                      subtitle,
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: ColorConstants.getTextColor(context)
                              .withValues(alpha: 0.6)),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (onPressed != null) ...[
                    10.width(),
                    SvgPicture.asset(
                      "assets/svg/common/arrow_right_rounded.svg",
                      colorFilter: ColorFilter.mode(
                          ColorConstants.getThemeColor(context),
                          BlendMode.srcIn),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
