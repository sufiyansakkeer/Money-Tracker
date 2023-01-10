import 'package:flutter/material.dart';

var nameOfTheUser = 'Sufiyan';

class NavigationDrawer extends StatelessWidget {
  const NavigationDrawer({super.key});

  @override
  Widget build(BuildContext context) => Container(
        height: 1000,
        decoration: BoxDecoration(
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
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                buildHeader(
                  context,
                ),
                buildMenuItems(
                  context,
                ),
              ],
            ),
          ),
        ),
      );
  Widget buildHeader(
    BuildContext context,
  ) =>
      SafeArea(
        child: Column(
          children: [
            ListTile(
              title: Text(
                '$nameOfTheUser',
              ),
            )
          ],
        ),
      );
  Widget buildMenuItems(BuildContext context) => Container(
        padding: EdgeInsets.all(15),
        child: Wrap(
          runSpacing: 10,
          children: [
            ListTile(
              title: Text(
                'Help',
              ),
              leading: Icon(
                Icons.help_outline,
                color: Colors.blue,
              ),
            ),
            ListTile(
              title: Text(
                'Help',
              ),
              leading: Icon(
                Icons.help_outline,
                color: Colors.blue,
              ),
            ),
            ListTile(
              title: Text(
                'Help',
              ),
              leading: Icon(
                Icons.help_outline,
                color: Colors.blue,
              ),
            ),
            ListTile(
              title: Text(
                'Help',
              ),
              leading: Icon(
                Icons.help_outline,
                color: Colors.blue,
              ),
            ),
          ],
        ),
      );
}
