import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:money_track/constants/color/colors.dart';
import 'package:money_track/db/category/db_category.dart';
import 'package:money_track/db/transaction/db_transaction_function.dart';
import 'package:money_track/models/categories_model/category_model.dart';
import 'package:money_track/models/transaction_model/transaction_model.dart';
import 'package:money_track/screens/splash_screen.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
                onTap: () {
                  Share.share(
                      'hey! check out this new app https://play.google.com/store/search?q=money%20tracker&c=apps');
                },
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
