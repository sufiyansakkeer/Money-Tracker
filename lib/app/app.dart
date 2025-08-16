import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:money_track/app/di/injection_container.dart';
import 'package:money_track/app/routes/app_routes.dart';
import 'package:money_track/features/onboarding/presentation/bloc/on_boarding_cubit.dart';
import 'package:money_track/features/profile/presentation/bloc/theme/theme_cubit.dart';
import 'package:money_track/features/profile/presentation/bloc/theme/theme_state.dart';
import 'package:money_track/features/navigation/presentation/bloc/bottom_navigation_bloc.dart';
import 'package:money_track/features/categories/presentation/bloc/category_bloc.dart';
import 'package:money_track/features/transactions/presentation/bloc/transaction_bloc.dart';
import 'package:money_track/features/transactions/presentation/bloc/total_transaction/total_transaction_cubit.dart';
import 'package:money_track/features/profile/presentation/bloc/currency/currency_cubit.dart';
import 'package:money_track/features/budget/presentation/bloc/budget_bloc.dart';
import 'package:money_track/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:money_track/core/presentation/bloc/sync_cubit.dart';

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
          create: (_) => sl<BottomNavigationBloc>(),
        ),
        BlocProvider(
          create: (_) => sl<CategoryBloc>(),
        ),
        BlocProvider(
          create: (_) => sl<TransactionBloc>(),
        ),
        BlocProvider(
          create: (_) => sl<TotalTransactionCubit>(),
        ),
        BlocProvider(
          create: (_) => OnBoardingCubit(),
        ),
        BlocProvider(
          create: (_) => sl<CurrencyCubit>(),
        ),
        BlocProvider(
          create: (_) => sl<ThemeCubit>()..loadTheme(),
        ),
        BlocProvider(
          create: (_) => sl<BudgetBloc>(),
        ),
        BlocProvider(
          create: (_) => sl<AuthBloc>(),
        ),
        BlocProvider(
          create: (_) => sl<SyncCubit>(),
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
