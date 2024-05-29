import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:money_track/core/constants/colors.dart';

import 'package:money_track/models/categories_model/category_model.dart';
import 'package:money_track/models/transaction_model/transaction_model.dart';
import 'package:money_track/view/navigation_drawer/widgets/about_page.dart';
import 'package:money_track/view/screens/splash_screen.dart';

import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                buildMenuItems(
                  context,
                ),
                const Padding(
                  padding: EdgeInsets.all(30.0),
                  child: Text('V 1.0.2'),
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
              elevation: 8,
              shape: RoundedRectangleBorder(
                //<-- SEE HERE
                // side: BorderSide(width: 1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: ListTile(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: ((context) {
                        return const AboutPage();
                      }),
                    ),
                  );
                },
                title: Text(
                  'About',
                  style: TextStyle(
                    fontSize: 16,
                    color: ColorConstants.themeDarkBlue,
                  ),
                ),
                leading: Icon(
                  Icons.info_rounded,
                  color: ColorConstants.themeDarkBlue,
                ),
              ),
            ),
            Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                //<-- SEE HERE
                // side: BorderSide(width: 1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: ListTile(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (ctx) {
                      return AlertDialog(
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(15),
                          ),
                        ),
                        actions: [
                          TextButton(
                              onPressed: () => Navigator.of(ctx).pop(),
                              child: const Text(
                                'No',
                                style: TextStyle(color: Colors.blueGrey),
                              )),
                          const SizedBox(
                            width: 30,
                          ),
                          TextButton(
                            onPressed: () async {
                              SharedPreferences pref =
                                  await SharedPreferences.getInstance();
                              await pref.clear();
                              // TransactionDB.instance.resetApp();
                              // resetApp();
                              final categoryDB =
                                  await Hive.openBox<CategoryModel>(
                                      'category-database');

                              categoryDB.clear();

                              final transactionDb =
                                  await Hive.openBox<TransactionModel>(
                                      'Transaction-database');

                              transactionDb.clear();
                              // Hive.box('category-database').clear();
                              // Hive.box('Transaction-database').clear();

                              // ignore: use_build_context_synchronously
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                  builder: (context) => const SplashScreen(),
                                ),
                              );
                            },
                            child: const Text(
                              'Yes',
                              style: TextStyle(color: Colors.red),
                            ),
                          )
                        ],
                        title: const Text("Reset App"),
                        content: const Text(
                            "Are you sure you want to reset the app?"),
                      );
                    },
                  );
                },
                title: Text(
                  'Reset',
                  style: TextStyle(
                    color: ColorConstants.themeDarkBlue,
                    fontSize: 16,
                  ),
                ),
                leading: Icon(
                  Icons.restart_alt_rounded,
                  color: ColorConstants.themeDarkBlue,
                  size: 25,
                ),
              ),
            ),
            Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                //<-- SEE HERE
                // side: BorderSide(width: 1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: ListTile(
                onTap: () {
                  Share.share(
                      'hey! check out this new app https://play.google.com/store/apps/details?id=in.brototype.money_track');
                },
                title: Text(
                  'Share',
                  style: TextStyle(
                    fontSize: 16,
                    color: ColorConstants.themeDarkBlue,
                  ),
                ),
                leading: Icon(
                  Icons.adaptive.share,
                  color: ColorConstants.themeDarkBlue,
                ),
              ),
            ),
            Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                //<-- SEE HERE
                // side: BorderSide(width: 1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: ListTile(
                onTap: () async {
                  const url =
                      'mailto:sufiyansakkeer616@gmail.com?subject=Help me&body=need help';
                  Uri uri = Uri.parse(url);

                  await launchUrl(uri);
                },
                title: Text(
                  'Feedback',
                  style: TextStyle(
                    fontSize: 16,
                    color: ColorConstants.themeDarkBlue,
                  ),
                ),
                leading: Icon(
                  Icons.chat_outlined,
                  color: ColorConstants.themeDarkBlue,
                ),
              ),
            ),
            // Card(
            //   elevation: 8,
            //   shape: RoundedRectangleBorder(
            //     //<-- SEE HERE
            //     // side: BorderSide(width: 1),
            //     borderRadius: BorderRadius.circular(20),
            //   ),
            //   child: ListTile(
            //     onTap: () {},
            //     title: const Text(
            //       'Privacy Policy',
            //       style: TextStyle(
            //         fontSize: 16,
            //         color:ColorConstants. themeDarkBlue,
            //       ),
            //     ),
            //     leading: const Icon(
            //       Icons.description,
            //       color:ColorConstants. themeDarkBlue,
            //     ),
            //   ),
            // ),
          ],
        ),
      );
}
