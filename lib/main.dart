import 'package:device_preview/device_preview.dart'
    show DevicePreview;
import 'package:firebase_app_check/firebase_app_check.dart'
    show FirebaseAppCheck, AndroidProvider, WebDebugProvider;
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart'
    show kReleaseMode;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app/app.dart';
import 'firebase_options.dart';

// ============================================================
// ACTIVITY
// ============================================================

import 'features/activity/data/datasources/activity_remote_data_source.dart';
import 'features/activity/data/repositories/activity_repository_impl.dart';
import 'features/activity/domain/usecases/add_activity.dart';
import 'features/activity/domain/usecases/delete_activity.dart';
import 'features/activity/domain/usecases/get_activities.dart';
import 'features/activity/presentation/providers/activity_provider.dart';

// ============================================================
// AUTH
// ============================================================

import 'features/authentication/presentation/providers/auth_provider.dart';

// ============================================================
// WATER
// ============================================================

import 'features/water/data/datasources/water_remote_data_source.dart';
import 'features/water/presentation/providers/water_provider.dart';

// ============================================================
// DIET
// ============================================================

import 'features/diet/data/datasources/diet_remote_data_resource.dart';
import 'features/diet/presentation/providers/diet_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ============================================================
  // FIREBASE
  // ============================================================

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // ============================================================
  // FIREBASE APP CHECK
  // ============================================================

  await FirebaseAppCheck.instance.activate(
    androidProvider: AndroidProvider.debug,
    webProvider: WebDebugProvider(),
  );

  // ============================================================
  // ACTIVITY DEPENDENCIES
  // ============================================================

  final ActivityRemoteDataSource activityDataSource =
  ActivityRemoteDataSource();

  final ActivityRepositoryImpl activityRepository =
  ActivityRepositoryImpl(
    remoteDataSource: activityDataSource,
  );

  final AddActivity addActivity =
  AddActivity(
    repository: activityRepository,
  );

  final GetActivities getActivities =
  GetActivities(
    repository: activityRepository,
  );

  final DeleteActivity deleteActivity =
  DeleteActivity(
    repository: activityRepository,
  );

  // ============================================================
  // WATER DEPENDENCY
  // ============================================================

  final WaterRemoteDataSource waterDataSource =
  WaterRemoteDataSource();

  // ============================================================
  // DIET DEPENDENCY
  // ============================================================

  final DietRemoteDataSource dietDataSource =
  DietRemoteDataSource();

  // ============================================================
  // RUN APP
  // ============================================================

  runApp(
    DevicePreview(
      enabled: !kReleaseMode,
      builder: (context) {
        return MultiProvider(
          providers: [
            // ==================================================
            // AUTH
            // ==================================================

            ChangeNotifierProvider<AuthProvider>(
              create: (_) => AuthProvider(),
            ),

            // ==================================================
            // ACTIVITY
            // ==================================================

            ChangeNotifierProvider<ActivityProvider>(
              create: (_) => ActivityProvider(
                addActivity: addActivity,
                getActivities: getActivities,
                deleteActivity: deleteActivity,
              )..startListening(),
            ),

            // ==================================================
            // WATER
            // ==================================================

            ChangeNotifierProvider<WaterProvider>(
              create: (_) => WaterProvider(
                dataSource: waterDataSource,
              )..startListening(),
            ),

            // ==================================================
            // DIET
            // ==================================================

            ChangeNotifierProvider<DietProvider>(
              create: (_) => DietProvider(
                dataSource: dietDataSource,
              )..startListening(),
            ),
          ],

          // ====================================================
          // APP
          // ====================================================

          child: const FitnessTrackerApp(),
        );
      },
    ),
  );
}