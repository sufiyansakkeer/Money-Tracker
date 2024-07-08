import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:money_track/presentation/bloc/bottom_navigation/bottom_navigation_bloc.dart';
import 'presentation/bloc/on_boarding/on_boarding_cubit.dart';
import 'presentation/bloc/transaction/total_transaction/total_transaction_cubit.dart';
import 'presentation/bloc/transaction/transaction_bloc.dart';
import 'presentation/bloc/category/category_bloc.dart';
import 'presentation/pages/splash_screen/splash_screen.dart';

GlobalKey<ScaffoldMessengerState> snackBarKey = GlobalKey();

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
        BlocProvider(
          create: (context) => CategoryBloc(),
        ),
        BlocProvider(
          create: (context) => TransactionBloc(),
        ),
        BlocProvider(
          create: (context) => TotalTransactionCubit(),
        ),
        BlocProvider(
          create: (context) => OnBoardingCubit(),
        ),
      ],
      child: MaterialApp(
        scaffoldMessengerKey: snackBarKey,
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
            useMaterial3: true,
            fontFamily: GoogleFonts.oxygen().fontFamily,
            scaffoldBackgroundColor: Colors.white,
            appBarTheme: const AppBarTheme(backgroundColor: Colors.white)),
        // themeMode: MediaQuery.platformBrightnessOf(context) == Brightness.dark
        //     ? ThemeMode.dark
        //     : ThemeMode.light,
        // home: const SplashScreen(), // when you initialize initial route no need to declare initial
        initialRoute: "/",
        routes: {
          "/": (context) => const SplashScreen(),
          // AddTransaction.routeName: (context) => const AddTransaction(),
        },
      ),
    );
  }
}
