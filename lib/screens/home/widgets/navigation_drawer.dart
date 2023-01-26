import 'package:flutter/material.dart';
import 'package:money_track/constants/color/colors.dart';

var nameOfTheUser = 'Sufiyan';

class NavigationDrawerClass extends StatelessWidget {
  const NavigationDrawerClass({super.key});

  @override
  Widget build(BuildContext context) => Container(
        height: 1000,
        decoration: const BoxDecoration(
          // color: Color(0xFF2E49FB),

          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(50),
            bottomRight: Radius.circular(50),
          ),
        ),
        child: Drawer(
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topRight: Radius.circular(15),
                bottomRight: Radius.circular(15)),
          ),
          child: SafeArea(
            child: Column(
              children: <Widget>[
                buildMenuItems(
                  context,
                ),
              ],
            ),
          ),
        ),
      );

  Widget buildMenuItems(BuildContext context) => Container(
        padding: const EdgeInsets.all(15),
        child: Wrap(
          runSpacing: 10,
          children: [
            Card(
              shape: RoundedRectangleBorder(
                //<-- SEE HERE
                // side: BorderSide(width: 1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: ListTile(
                onTap: () {},
                title: const Text(
                  'Reset',
                  style: TextStyle(
                    color: themeDarkBlue,
                    fontSize: 16,
                  ),
                ),
                leading: const Icon(
                  Icons.restart_alt_rounded,
                  color: themeDarkBlue,
                  size: 25,
                ),
              ),
            ),
            Card(
              shape: RoundedRectangleBorder(
                //<-- SEE HERE
                // side: BorderSide(width: 1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: ListTile(
                onTap: () {},
                title: const Text(
                  'Share',
                  style: TextStyle(
                    fontSize: 16,
                    color: themeDarkBlue,
                  ),
                ),
                leading: Icon(
                  Icons.adaptive.share,
                  color: themeDarkBlue,
                ),
              ),
            ),
            Card(
              shape: RoundedRectangleBorder(
                //<-- SEE HERE
                // side: BorderSide(width: 1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: ListTile(
                onTap: () {},
                title: const Text(
                  'Privacy Policy',
                  style: TextStyle(
                    fontSize: 16,
                    color: themeDarkBlue,
                  ),
                ),
                leading: const Icon(
                  Icons.description,
                  color: themeDarkBlue,
                ),
              ),
            ),
            Card(
              shape: RoundedRectangleBorder(
                //<-- SEE HERE
                // side: BorderSide(width: 1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: ListTile(
                onTap: () {},
                title: const Text(
                  'About',
                  style: TextStyle(
                    fontSize: 16,
                    color: themeDarkBlue,
                  ),
                ),
                leading: const Icon(
                  Icons.info_rounded,
                  color: themeDarkBlue,
                ),
              ),
            ),
          ],
        ),
      );
}
