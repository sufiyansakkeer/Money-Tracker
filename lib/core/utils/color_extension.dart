import 'package:flutter/material.dart';

/// Extension methods for the [Color] class
extension ColorExtension on Color {
  /// Creates a new color with the same RGB values but with a modified alpha value.
  /// 
  /// The [alpha] parameter can be:
  /// - A double between 0.0 and 1.0, which will be multiplied by 255 and rounded to the nearest integer
  /// - An integer between 0 and 255, which will be used directly
  /// 
  /// Example usage:
  /// ```dart
  /// // Using a double (0.0 to 1.0)
  /// final transparentRed = Colors.red.withValues(alpha: 0.5); // 50% opacity
  /// 
  /// // Using an integer (0 to 255)
  /// final semiTransparentBlue = Colors.blue.withValues(alpha: 128); // 50% opacity
  /// ```
  Color withValues({int? alpha}) {
    if (alpha == null) {
      return this;
    }
    
    // If alpha is between 0 and 1, convert it to 0-255 range
    final normalizedAlpha = alpha > 1 && alpha <= 255 
        ? alpha 
        : (alpha * 255).round().clamp(0, 255);
    
    return withAlpha(normalizedAlpha);
  }
}
