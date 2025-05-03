import 'package:flutter/material.dart';
import 'package:money_track/core/utils/sized_box_extension.dart';
import 'package:money_track/core/utils/widget_extension.dart';
import 'package:svg_flutter/svg.dart';

class SourceTile extends StatelessWidget {
  const SourceTile({
    super.key,
    required this.color,
    required this.sourceName,
    required this.sourceData,
    required this.sourceIcon,
    this.padding,
  });
  final Color color;
  final String sourceName;
  final double sourceData;
  final String sourceIcon;
  final EdgeInsetsGeometry? padding;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 190,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(
          20,
        ),
      ),
      padding: padding ??
          const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 16,
          ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SvgPicture.asset(
            sourceIcon,
          ),
          10.width(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                sourceName,
                style: const TextStyle(
                  color: Colors.white,
                ),
              ),
              Text(
                "₹$sourceData",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ).flexible(),
        ],
      ),
    );
  }
}
