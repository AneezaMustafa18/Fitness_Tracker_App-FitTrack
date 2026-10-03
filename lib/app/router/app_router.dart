import 'package:flutter/material.dart';

import '../../features/onboarding/presentation/screens/splash_screen_1.dart';
import '../../features/authentication/presentation/screens/login_screen.dart';
import '../../features/authentication/presentation/screens/signup_screen.dart';
import '../../features/dashboard/data/domain/presentation/screens/home_screen.dart';

class AppRouter {
  AppRouter._();

  static Route<dynamic> onGenerateRoute(
      RouteSettings settings,
      ) {
    switch (settings.name) {
    // ==========================================================
    // SPLASH
    // ==========================================================

      case '/':
        return MaterialPageRoute(
          builder: (_) => const SplashScreen1(),
        );

    // ==========================================================
    // LOGIN
    // ==========================================================

      case '/login':
      case '/LoginScreen':
        return MaterialPageRoute(
          builder: (_) => const LoginScreen(),
        );

    // ==========================================================
    // SIGNUP
    // ==========================================================

      case '/signup':
      case '/SignupScreen':
        return MaterialPageRoute(
          builder: (_) => const SignupScreen(),
        );

    // ==========================================================
    // HOME
    // ==========================================================

      case '/home':
      case '/HomeScreen':
        return MaterialPageRoute(
          builder: (_) => const HomeScreen(),
        );

    // ==========================================================
    // UNKNOWN ROUTE
    // ==========================================================

      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(
              child: Text(
                'Page not found',
              ),
            ),
          ),
        );
    }
  }
}