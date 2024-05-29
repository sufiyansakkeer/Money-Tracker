import 'package:flutter/material.dart';
import 'package:money_track/config/theme/theme.dart';
import 'package:money_track/core/constants/colors.dart';
import 'package:money_track/provider/add_transaction_provider.dart';
import 'package:money_track/provider/category_provider.dart';
import 'package:money_track/provider/category_type_provider.dart';
import 'package:money_track/provider/income_expense.dart';
import 'package:money_track/provider/onboarding_screen.dart';
import 'package:money_track/provider/transaction_provider.dart';
import 'package:money_track/view/screens/splash_screen.dart';
import 'package:provider/provider.dart';

class MyApp extends StatelessWidget {
  const MyApp({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (BuildContext context) => ProviderTransaction(),
        ),
        ChangeNotifierProvider(
          create: (BuildContext context) => OnBoardingProvider(),
        ),
        ChangeNotifierProvider(
          create: (BuildContext context) => IncomeAndExpense(),
        ),
        ChangeNotifierProvider(
          create: (BuildContext context) => CategoryProvider(),
        ),
        ChangeNotifierProvider(
          create: (BuildContext context) => AddTransactionProvider(),
        ),
        ChangeNotifierProvider(
          create: (BuildContext context) => CategoryTypeProvider(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primaryColor: ColorConstants.themeDarkBlue,
          primarySwatch: createMaterialColor(
            ColorConstants.themeDarkBlue,
          ),
          // useMaterial3: true,
          // fontFamily: google,
        ),
        darkTheme: ThemeData(
          useMaterial3: true,
          primaryColor: ColorConstants.themeDarkBlue,
          primaryColorDark: ColorConstants.themeDarkBlue,
          primarySwatch: createMaterialColor(ColorConstants.themeDarkBlue),
          scaffoldBackgroundColor: const Color(0xFF333333),
          colorScheme: const ColorScheme.dark(),
        ),
        themeMode: MediaQuery.platformBrightnessOf(context) == Brightness.dark
            ? ThemeMode.dark
            : ThemeMode.light,
        home: const SplashScreen(),
        routes: const {
          // AddTransaction.routeName: (context) => const AddTransaction(),
        },
      ),
    );
  }
}
