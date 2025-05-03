// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:money_track/app/di/injection_container.dart';
// import 'package:money_track/features/onboarding/presentation/bloc/on_boarding_cubit.dart';
// import 'package:money_track/features/splash/presentation/pages/splash_screen.dart';

// GlobalKey<ScaffoldMessengerState> snackBarKey = GlobalKey();

// class MyApp extends StatelessWidget {
//   const MyApp({
//     super.key,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return MultiBlocProvider(
//       providers: [
//         BlocProvider(
//           create: (context) => sl.bottomNavigationBloc,
//         ),
//         BlocProvider(
//           create: (context) => sl.categoryBloc,
//         ),
//         BlocProvider(
//           create: (context) => sl.transactionBloc,
//         ),
//         BlocProvider(
//           create: (context) => sl.totalTransactionCubit,
//         ),
//         BlocProvider(
//           create: (context) => OnBoardingCubit(),
//         ),
//       ],
//       child: MaterialApp(
//         scaffoldMessengerKey: snackBarKey,
//         debugShowCheckedModeBanner: false,
//         theme: ThemeData(
//             useMaterial3: true,
//             fontFamily: GoogleFonts.oxygen().fontFamily,
//             scaffoldBackgroundColor: Colors.white,
//             appBarTheme: const AppBarTheme(backgroundColor: Colors.white)),
//         // themeMode: MediaQuery.platformBrightnessOf(context) == Brightness.dark
//         //     ? ThemeMode.dark
//         //     : ThemeMode.light,
//         // home: const SplashScreen(), // when you initialize initial route no need to declare initial
//         initialRoute: "/",
//         routes: {
//           "/": (context) => const SplashScreen(),
//           // AddTransaction.routeName: (context) => const AddTransaction(),
//         },
//       ),
//     );
//   }
// }
