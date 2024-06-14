import 'package:flutter/material.dart';
import 'package:money_track/core/constants/colors.dart';
import 'package:money_track/helper/sized_box_extension.dart';
import 'package:svg_flutter/svg_flutter.dart';

class SettingsTile extends StatelessWidget {
  const SettingsTile({
    super.key,
    required this.title,
    required this.subtitle,
    this.onPressed,
    this.tag,
  });
  final String title;
  final String subtitle;
  final void Function()? onPressed;
  final String? tag;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Hero(
              tag: tag ?? "",
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
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
