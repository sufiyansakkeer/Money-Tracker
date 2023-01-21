import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';

class DateFilterClass extends StatelessWidget {
  const DateFilterClass({super.key});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton(
        icon: Icon(Icons.filter_alt_outlined),
        itemBuilder: ((context) => [
              PopupMenuItem(
                child: Text("All"),
              ),
              PopupMenuItem(
                child: Text("Day"),
              ),
              PopupMenuItem(
                child: Text("Month"),
              ),
              PopupMenuItem(
                child: Text("Year"),
              ),
            ]));
  }
}
