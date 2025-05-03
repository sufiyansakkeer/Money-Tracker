import 'package:flutter/material.dart';

extension DoubleSizedBox on int {
  SizedBox height() => SizedBox(height: toDouble());
  SizedBox width() => SizedBox(width: toDouble());
}
