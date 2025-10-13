import 'package:flutter/material.dart';
import 'package:money_track/features/splash/presentation/pages/splash_screen.dart';
import 'package:money_track/features/auth/presentation/pages/login_page.dart';
import 'package:money_track/features/auth/presentation/pages/register_page.dart';
import 'package:money_track/features/auth/presentation/pages/forgot_password_page.dart';
import 'package:money_track/features/navigation/presentation/pages/bottom_navigation_page.dart';
import 'package:money_track/features/onboarding/presentation/pages/onboard_screen.dart';

/// App routes configuration
class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
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
      case login:
        return MaterialPageRoute(
          builder: (_) => const LoginPage(),
        );
      case register:
        return MaterialPageRoute(
          builder: (_) => const RegisterPage(),
        );
      case forgotPassword:
        return MaterialPageRoute(
          builder: (_) => const ForgotPasswordPage(),
        );
      case home:
        return MaterialPageRoute(
          builder: (_) => const BottomNavigationPage(),
        );
      case onboarding:
        return MaterialPageRoute(
          builder: (_) => const OnboardScreen(),
        );
      default:
        return MaterialPageRoute(
          builder: (_) => const SplashScreen(),
        );
    }
  }
}
