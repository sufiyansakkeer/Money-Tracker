import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:money_track/config/theme/theme.dart';
import 'package:money_track/presentation/bloc/bottom_navigation/bottom_navigation_bloc.dart';
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
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => BottomNavigationBloc(),
        ),
      ],
      child: MultiProvider(
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
          theme: getThemeData(context),
          // themeMode: MediaQuery.platformBrightnessOf(context) == Brightness.dark
          //     ? ThemeMode.dark
          //     : ThemeMode.light,
          home: const SplashScreen(),
          routes: const {
            // AddTransaction.routeName: (context) => const AddTransaction(),
          },
        ),
      ),
    );
  }
}
