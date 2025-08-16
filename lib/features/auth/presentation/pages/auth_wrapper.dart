import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:money_track/core/widgets/enhanced_widgets.dart';
import 'package:money_track/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:money_track/features/auth/presentation/pages/login_page.dart';
import 'package:money_track/features/navigation/presentation/pages/bottom_navigation_page.dart';
import 'package:money_track/features/onboarding/presentation/pages/onboard_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Wrapper that handles authentication state and routing
class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _isFirstTime = true;
  bool _isCheckingFirstTime = true;

  @override
  void initState() {
    super.initState();
    _checkFirstTime();
    // Check authentication status when the widget is initialized
    context.read<AuthBloc>().add(CheckAuthStatusEvent());
  }

  Future<void> _checkFirstTime() async {
    final prefs = await SharedPreferences.getInstance();
    final seen = prefs.getBool('seen') ?? false;
    
    setState(() {
      _isFirstTime = !seen;
      _isCheckingFirstTime = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isCheckingFirstTime) {
      return const Scaffold(
        body: Center(
          child: AppLoadingWidget(message: "Loading..."),
        ),
      );
    }

    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        // Show loading while checking authentication
        if (state is AuthInitial || state is AuthLoading) {
          return const Scaffold(
            body: Center(
              child: AppLoadingWidget(message: "Checking authentication..."),
            ),
          );
        }

        // If user is authenticated, show main app
        if (state is AuthAuthenticated) {
          return const BottomNavigationPage();
        }

        // If user is not authenticated, check if it's first time
        if (_isFirstTime) {
          return const OnboardScreen();
        }

        // Show login page for returning users who are not authenticated
        return const LoginPage();
      },
    );
  }
}
