import 'package:animations/animations.dart';
import 'package:flutter/material.dart';

import 'package:money_track/home/widgets/add_screen.dart';

const double fabSize = 56;

class CustomFABWidget extends StatelessWidget {
  const CustomFABWidget({super.key});

  // final ContainerTransitionType transitionType;

  @override
  Widget build(BuildContext context) => OpenContainer(
        transitionDuration: const Duration(milliseconds: 500),
        openBuilder: (context, _) => AddTransaction(),
        closedShape: const CircleBorder(),
        closedColor: Theme.of(context).primaryColor,
        closedBuilder: (context, openContainer) => Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Theme.of(context).primaryColor,
          ),
          height: fabSize,
          width: fabSize,
          child: const Icon(
            Icons.add,
            color: Colors.white,
          ),
        ),
      );
}
