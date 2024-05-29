import 'package:flutter/material.dart';

class CustomInkWell extends StatelessWidget {
  final Widget child;
  final void Function()? onTap;

  const CustomInkWell({
    super.key,
    required this.child,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      splashColor: Colors.transparent,
      splashFactory: NoSplash.splashFactory,
      highlightColor: Colors.transparent, // constant parameter
      child: child,
    );
  }
}
