import 'package:flutter/material.dart';

extension WidgetExtensions on Widget {
  /// Wraps the widget with an Expanded widget
  Expanded expand() => Expanded(child: this);

  /// Wraps the widget with a Flexible widget
  Flexible flexible({int flex = 1, FlexFit fit = FlexFit.loose}) =>
      Flexible(flex: flex, fit: fit, child: this);
}
