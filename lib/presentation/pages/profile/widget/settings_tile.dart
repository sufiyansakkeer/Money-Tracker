import 'package:flutter/material.dart';
import 'package:money_track/core/constants/colors.dart';
import 'package:money_track/helper/sized_box_extension.dart';
import 'package:svg_flutter/svg_flutter.dart';

class ProfileTile extends StatelessWidget {
  const ProfileTile({
    super.key,
    required this.title,
    required this.subtitle,
    this.onPressed,
  });
  final String title;
  final String subtitle;
  final void Function()? onPressed;
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
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            Row(
              children: [
                Text(
                  subtitle,
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey),
                ),
                10.width(),
                if (title != "")
                  SvgPicture.asset(
                    "assets/svg/common/arrow_right_rounded.svg",
                    colorFilter: ColorFilter.mode(
                        ColorConstants.themeColor, BlendMode.srcIn),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
