import 'package:flutter/material.dart';
import 'package:money_track/core/constants/colors.dart';
import 'package:svg_flutter/svg_flutter.dart';

class GraphFilterIcon extends StatelessWidget {
  const GraphFilterIcon({
    super.key,
    required this.onTap,
  });
  
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
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
      ),
    );
  }
}
