import 'package:flutter/material.dart';
import 'package:money_track/core/constants/colors.dart';
import 'package:money_track/core/utils/sized_box_extension.dart';
import 'package:svg_flutter/svg.dart';

class DateFilterIcon extends StatelessWidget {
  const DateFilterIcon({
    super.key,
    required this.dateType,
  });
  final String dateType;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        border: Border.all(
          color: ColorConstants.borderColor,
        ),
        borderRadius: BorderRadius.circular(
          30,
        ),
      ),
      child: Row(
        children: [
          SvgPicture.asset(
            "assets/svg/common/arrow_down_rounded.svg",
            colorFilter: ColorFilter.mode(
              ColorConstants.themeColor,
              BlendMode.srcIn,
            ),
          ),
          5.width(),
          Text(
            dateType,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class SortIconWidget extends StatelessWidget {
  const SortIconWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border.all(
          color: ColorConstants.borderColor,
        ),
        borderRadius: BorderRadius.circular(
          30,
        ),
      ),
      child: SvgPicture.asset(
        "assets/svg/common/sort.svg",
        colorFilter: ColorFilter.mode(
          ColorConstants.themeColor,
          BlendMode.srcIn,
        ),
      ),
    );
  }
}
