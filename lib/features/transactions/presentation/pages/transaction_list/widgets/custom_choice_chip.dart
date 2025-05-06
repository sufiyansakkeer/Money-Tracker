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
    return ChoiceChip(
      selectedColor: ColorConstants.getSecondaryColor(context),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
          20,
        ),
      ),
      label: Text(
        name,
        style: TextStyle(
          color: selected
              ? ColorConstants.getThemeColor(context)
              : ColorConstants.getTextColor(context),
          fontWeight: FontWeight.bold,
        ),
      ),
      checkmarkColor: ColorConstants.getThemeColor(context),
      selected: selected,
      onSelected: onSelected,
    );
  }
}
