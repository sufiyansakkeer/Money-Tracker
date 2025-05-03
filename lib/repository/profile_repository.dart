import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:money_track/core/constants/db_constants.dart';
import 'package:money_track/features/splash/presentation/pages/splash_screen.dart';
import 'package:money_track/data/models/category_model.dart';
import 'package:money_track/data/models/transaction_model.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfileRepository {
  navigateToMail() async {
    const url =
        'mailto:sufiyansakkeer616@gmail.com?subject=Help me&body=need help';
    Uri uri = Uri.parse(url);

    await launchUrl(uri);
  }

  clearDB({required BuildContext context}) async {
    try {
      SharedPreferences pref = await SharedPreferences.getInstance();
      await pref.clear();
      // TransactionDB.instance.resetApp();
      // resetApp();
      final categoryDB =
          await Hive.openBox<CategoryModel>(DBConstants.categoryDbName);

      categoryDB.clear();

      final transactionDb =
          await Hive.openBox<TransactionModel>(DBConstants.transactionDbName);

      transactionDb.clear();
      // Hive.box('category-database').clear();
      // Hive.box('Transaction-database').clear();
      if (context.mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const SplashScreen(),
          ),
        );
      }
    } catch (e) {
      if (kDebugMode) {
        log(e.toString(), name: "clear db Exception");
      }
    }
  }
}
