import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:money_track/app/di/injection_container.dart';
import 'package:money_track/app/routes/app_routes.dart';

import 'package:money_track/features/onboarding/presentation/bloc/on_boarding_cubit.dart';

/// Global key for SnackBar
GlobalKey<ScaffoldMessengerState> snackBarKey = GlobalKey();

/// Main app widget
class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => sl.bottomNavigationBloc,
        ),
        BlocProvider(
          create: (context) => sl.categoryBloc,
        ),
        BlocProvider(
          create: (context) => sl.transactionBloc,
        ),
        BlocProvider(
          create: (context) => sl.totalTransactionCubit,
        ),
        BlocProvider(
          create: (context) => OnBoardingCubit(),
        ),
        BlocProvider(
          create: (context) => sl.currencyCubit,
        ),
      ],
      child: MaterialApp(
        scaffoldMessengerKey: snackBarKey,
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          fontFamily: GoogleFonts.oxygen().fontFamily,
          scaffoldBackgroundColor: Colors.white,
          appBarTheme: const AppBarTheme(backgroundColor: Colors.white),
        ),
        initialRoute: AppRoutes.splash,
        onGenerateRoute: AppRoutes.onGenerateRoute,
      ),
    );
  }
}
