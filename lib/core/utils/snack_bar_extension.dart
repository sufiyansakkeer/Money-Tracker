import 'package:flutter/material.dart';
import 'package:money_track/app/app.dart';

extension SnackBarExtension on String {
  /// snack bar extension
  /// ```dart
  /// "snack bar message".showSnack();
  /// ```
  ///
  void showSnack({Duration? duration, Color? backgroundColor}) {
    snackBarKey.currentState!.showSnackBar(SnackBar(
      behavior: SnackBarBehavior.floating,
      backgroundColor: backgroundColor,
      content: Text(this),
      duration: duration ?? const Duration(seconds: 3),
    ));
  }
}
