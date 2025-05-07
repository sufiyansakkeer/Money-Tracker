import 'package:flutter/material.dart';
import 'package:money_track/core/constants/colors.dart';

class CustomChoiceChip extends StatelessWidget {
  const CustomChoiceChip({
    super.key,
    required this.name,
    required this.selected,
    this.onSelected,
  });
  final String name;
  final bool selected;
  final void Function(bool value)? onSelected;

  @override
  Widget build(BuildContext context) {
    final themeColor = ColorConstants.getThemeColor(context);
    final secondaryColor = ColorConstants.getSecondaryColor(context);
    final textColor = ColorConstants.getTextColor(context);

    return ChoiceChip(
      selectedColor: secondaryColor,
      backgroundColor: Colors.transparent,
      side: BorderSide(
        color:
            selected ? Colors.transparent : themeColor.withValues(alpha: 0.5),
        width: 1.5,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      label: Text(
        name,
        style: TextStyle(
          color: selected ? themeColor : textColor,
          fontWeight: FontWeight.bold,
        ),
      ),
      checkmarkColor: themeColor,
      selected: selected,
      onSelected: onSelected,
    );
  }
}
