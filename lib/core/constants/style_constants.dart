import 'package:flutter/material.dart';
import 'package:money_track/core/constants/colors.dart';

class StyleConstants {
  static ButtonStyle elevatedButtonStyle({
    Color? backgroundColor,
  }) {
    return ElevatedButton.styleFrom(
      backgroundColor: backgroundColor ?? ColorConstants.themeColor,
      minimumSize: const Size(double.infinity, 55),
      enableFeedback: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    );
  }

  static OutlineInputBorder textFormFieldBorder() => OutlineInputBorder(
        // hintText:"Category",
        borderRadius: BorderRadius.circular(
          16,
        ),
        borderSide: const BorderSide(
          color: Color(0xFFE0E0E1),
        ),
      );
}
