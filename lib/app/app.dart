import 'package:fitness_tracker_app/app/router/app_router.dart' show AppRouter;
import 'package:fitness_tracker_app/features/onboarding/presentation/screens/splash_screen_1.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';



class FitnessTrackerApp extends StatelessWidget {
  const FitnessTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Fitness Tracker',

      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0174F3),
        ),
      ),

      home: const SplashScreen1(),

      // App routes
      onGenerateRoute: AppRouter.onGenerateRoute,
    );
  }
}