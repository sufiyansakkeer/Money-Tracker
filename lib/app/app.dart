import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:money_track/app/di/injection_container.dart';
import 'package:money_track/app/routes/app_routes.dart';
import 'package:money_track/features/onboarding/presentation/bloc/on_boarding_cubit.dart';
import 'package:money_track/features/profile/presentation/bloc/theme/theme_cubit.dart';
import 'package:money_track/features/profile/presentation/bloc/theme/theme_state.dart';

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
        BlocProvider(
          create: (context) => sl.themeCubit..loadTheme(),
        ),
      ],
      child: BlocBuilder<ThemeCubit, ThemeState>(
        builder: (context, state) {
          // Initialize theme
          if (state is ThemeInitial) {
            context.read<ThemeCubit>().loadTheme();
          }

          // Default theme data
          ThemeData lightThemeData = ThemeData(
            useMaterial3: true,
            fontFamily: GoogleFonts.oxygen().fontFamily,
            scaffoldBackgroundColor: Colors.white,
            appBarTheme: const AppBarTheme(backgroundColor: Colors.white),
          );

          ThemeData darkThemeData = ThemeData(
            brightness: Brightness.dark,
            useMaterial3: true,
            fontFamily: GoogleFonts.oxygen().fontFamily,
            scaffoldBackgroundColor: const Color(0xFF121212),
            appBarTheme: const AppBarTheme(backgroundColor: Color(0xFF1E1E1E)),
          );

          ThemeMode themeMode = ThemeMode.light;

          // Update theme data if loaded
          if (state is ThemeLoaded) {
            lightThemeData = state.lightThemeData;
            darkThemeData = state.darkThemeData;
            themeMode = state.appThemeMode;
          }

          return MaterialApp(
            scaffoldMessengerKey: snackBarKey,
            debugShowCheckedModeBanner: false,
            theme: lightThemeData,
            darkTheme: darkThemeData,
            themeMode: themeMode,
            initialRoute: AppRoutes.splash,
            onGenerateRoute: AppRoutes.onGenerateRoute,
          );
        },
      ),
    );
  }
}
