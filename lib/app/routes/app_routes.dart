import 'package:flutter/material.dart';
import 'package:money_track/features/splash/presentation/pages/splash_screen.dart';

/// App routes configuration
class AppRoutes {
  static const String splash = '/';
  static const String home = '/home';
  static const String addTransaction = '/add-transaction';
  static const String category = '/category';
  static const String profile = '/profile';
  static const String onboarding = '/onboarding';

  /// Route generator
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(
          builder: (_) => const SplashScreen(),
        );
      // Add other routes here
      default:
        return MaterialPageRoute(
          builder: (_) => const SplashScreen(),
        );
    }
  }
}
