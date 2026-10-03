import 'dart:math' as math;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'package:fitness_tracker_app/features/activity/domain/entities/activity.dart';
import 'package:fitness_tracker_app/features/activity/presentation/providers/activity_provider.dart';
import 'package:fitness_tracker_app/features/activity/presentation/screens/add_activity_screen.dart';
import 'package:fitness_tracker_app/features/activity/presentation/screens/history_screen.dart';
import 'package:fitness_tracker_app/features/activity/presentation/screens/live_tracking_screen.dart';

import 'package:fitness_tracker_app/features/profile/presentation/providers/profile_provider.dart';
import 'package:fitness_tracker_app/features/profile/presentation/screens/profile_screen.dart';

import 'package:fitness_tracker_app/features/water/presentation/providers/water_provider.dart';
import 'package:fitness_tracker_app/features/water/presentation/screens/add_water_screen.dart';

import 'package:fitness_tracker_app/features/diet/presentation/providers/diet_provider.dart';
import 'package:fitness_tracker_app/features/diet/presentation/screens/add_meal_screen.dart';

import 'package:fitness_tracker_app/features/ai_coach/presentation/screens/ai_coach_screen.dart';
import 'package:fitness_tracker_app/features/ai_coach/presentation/widgets/ai_coach_card.dart';

import '../../../../../../app/themes/app_colors.dart';
import '../widgets/overall_performance_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      context.read<ActivityProvider>().startListening();
      context.read<WaterProvider>().startListening();
      context.read<DietProvider>().startListening();
    });
  }

  // ===============================================================
  // RESPONSIVE SCALE
  // ===============================================================

  double _scale(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    final widthScale = size.width / 200.0;
    final heightScale = size.height / 302.0;

    return math.min(widthScale, heightScale).clamp(
      0.90,
      1.80,
    );
  }

  double _s(BuildContext context, double value) {
    return value * _scale(context);
  }

  // ===============================================================
  // ADD OPTIONS
  // ===============================================================

  void _showAddOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) {
        return SafeArea(
          child: Container(
            margin: const EdgeInsets.all(14),
            padding: const EdgeInsets.symmetric(
              vertical: 20,
              horizontal: 18,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 42,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),

                  const SizedBox(height: 18),

                  const Text(
                    'Add Activity',
                    style: TextStyle(
                      color: AppColors.normalText,
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  const SizedBox(height: 4),

                  const Text(
                    'Choose a category to log',
                    style: TextStyle(
                      color: AppColors.secondaryText,
                      fontSize: 12.5,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // LIVE TRACKING
                  _AddOptionTile(
                    icon: Icons.gps_fixed_rounded,
                    iconColor: AppColors.primaryBlue,
                    title: 'Live Tracking',
                    subtitle:
                    'GPS route, distance & pace tracked automatically',
                    onTap: () {
                      Navigator.pop(sheetContext);
                      _openLiveTracking(context);
                    },
                  ),

                  const SizedBox(height: 12),

                  // MANUAL EXERCISE
                  _AddOptionTile(
                    icon: Icons.fitness_center_rounded,
                    iconColor: Colors.orange,
                    title: 'Exercise (Manual)',
                    subtitle:
                    'Type in your workout details and save',
                    onTap: () {
                      Navigator.pop(sheetContext);
                      _openManualEntry(context);
                    },
                  ),

                  const SizedBox(height: 12),

                  // WATER
                  _AddOptionTile(
                    icon: Icons.water_drop_rounded,
                    iconColor: Colors.lightBlue,
                    title: 'Water Intake',
                    subtitle:
                    'Log a glass or bottle of water',
                    onTap: () {
                      Navigator.pop(sheetContext);
                      _openAddWater(context);
                    },
                  ),

                  const SizedBox(height: 12),

                  // DIET
                  _AddOptionTile(
                    icon: Icons.restaurant_rounded,
                    iconColor: Colors.green,
                    title: 'Diet / Meal',
                    subtitle:
                    'Log a meal with calories & macros',
                    onTap: () {
                      Navigator.pop(sheetContext);
                      _openAddMeal(context);
                    },
                  ),

                  const SizedBox(height: 6),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ===============================================================
  // EXISTING ADD NAVIGATION
  // ===============================================================

  void _openLiveTracking(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const LiveTrackingScreen(),
      ),
    );
  }

  void _openManualEntry(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const AddActivityScreen(),
      ),
    );
  }

  void _openAddWater(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const AddWaterScreen(),
      ),
    );
  }

  void _openAddMeal(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const AddMealScreen(),
      ),
    );
  }

  // ===============================================================
  // AI COACH NAVIGATION
  // ===============================================================

  void _openAICoach(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const AICoachScreen(),
      ),
    );
  }

  // ===============================================================
  // BOTTOM NAVIGATION
  // ===============================================================

  // Exercise tab -> AddActivityScreen
  void _openExercise(BuildContext context) {
    setState(() {
      _selectedIndex = 1;
    });

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const AddActivityScreen(),
      ),
    ).then((_) {
      if (!mounted) return;

      setState(() {
        _selectedIndex = 0;
      });
    });
  }

  // Diet tab -> AddMealScreen
  void _openDiet(BuildContext context) {
    setState(() {
      _selectedIndex = 2;
    });

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const AddMealScreen(),
      ),
    ).then((_) {
      if (!mounted) return;

      setState(() {
        _selectedIndex = 0;
      });
    });
  }

  // Water tab -> AddWaterScreen
  void _openWater(BuildContext context) {
    setState(() {
      _selectedIndex = 3;
    });

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const AddWaterScreen(),
      ),
    ).then((_) {
      if (!mounted) return;

      setState(() {
        _selectedIndex = 0;
      });
    });
  }

  // Profile tab -> ProfileScreen
  void _openProfile(BuildContext context) {
    setState(() {
      _selectedIndex = 4;
    });

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider<ProfileProvider>(
          create: (_) => ProfileProvider(),
          child: const ProfileScreen(),
        ),
      ),
    ).then((_) {
      if (!mounted) return;

      setState(() {
        _selectedIndex = 0;
      });
    });
  }

  // ===============================================================
  // BUILD
  // ===============================================================

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);

    return MediaQuery(
      data: mediaQuery.copyWith(
        textScaler: mediaQuery.textScaler.clamp(
          minScaleFactor: 0.85,
          maxScaleFactor: 1.0,
        ),
      ),
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: const SystemUiOverlayStyle(
          statusBarColor: AppColors.primaryBlue,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
        ),
        child: Scaffold(
          backgroundColor: AppColors.primaryBlue,
          resizeToAvoidBottomInset: false,
          bottomNavigationBar:
          _buildBottomNavigationBar(context),
          body: Column(
            children: [
              _buildHeaderArea(context),

              Expanded(
                child: Consumer<ActivityProvider>(
                  builder: (context, provider, child) {
                    final activities = provider.activities;

                    final totalSteps =
                    _totalSteps(activities);

                    final totalCalories =
                    _totalCalories(activities);

                    final totalDistance =
                    _totalDistance(activities);

                    final workoutCount =
                    _workoutCount(activities);

                    return RefreshIndicator(
                      color: AppColors.primaryBlue,
                      onRefresh: () async {
                        provider.startListening();
                      },
                      child: ListView(
                        physics:
                        const AlwaysScrollableScrollPhysics(),
                        padding: EdgeInsets.fromLTRB(
                          _s(context, 7),
                          _s(context, 5),
                          _s(context, 7),
                          _s(context, 6),
                        ),
                        children: [
                          _buildTodaySummary(
                            context,
                            totalSteps: totalSteps,
                          ),

                          SizedBox(
                            height: _s(context, 5),
                          ),

                          OverallPerformanceCard(
                            todayActivities:
                            _todayActivities(activities),
                          ),

                          SizedBox(
                            height: _s(context, 5),
                          ),

                          // =================================================
                          // AI FITNESS COACH
                          // =================================================

                          AICoachCard(
                            onTap: () {
                              _openAICoach(context);
                            },
                          ),

                          SizedBox(
                            height: _s(context, 5),
                          ),

                          _buildStatsRow(
                            context,
                            calories: totalCalories,
                            workouts: workoutCount,
                            distance: totalDistance,
                          ),

                          SizedBox(
                            height: _s(context, 5),
                          ),

                          _buildWeeklyCard(
                            context,
                            activities,
                          ),

                          SizedBox(
                            height: _s(context, 5),
                          ),

                          _buildRecentActivities(
                            context,
                            activities,
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ===============================================================
  // HEADER
  // ===============================================================

  Widget _buildHeaderArea(BuildContext context) {
    final topPadding =
        MediaQuery.paddingOf(context).top;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(top: topPadding),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primaryBlue,
            AppColors.primaryBlue.withValues(
              alpha: 0.82,
            ),
          ],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft:
          Radius.circular(_s(context, 22)),
          bottomRight:
          Radius.circular(_s(context, 22)),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue
                .withValues(alpha: 0.25),
            blurRadius: _s(context, 14),
            offset: Offset(
              0,
              _s(context, 6),
            ),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.only(
          bottomLeft:
          Radius.circular(_s(context, 22)),
          bottomRight:
          Radius.circular(_s(context, 22)),
        ),
        child: _buildTopHeader(context),
      ),
    );
  }

  Widget _buildTopHeader(BuildContext context) {
    final user =
        FirebaseAuth.instance.currentUser;

    final String displayName =
    (user?.displayName?.trim().isNotEmpty ??
        false)
        ? user!.displayName!
        .trim()
        .split(' ')
        .first
        : 'there';

    final String initial =
    displayName.isNotEmpty
        ? displayName[0].toUpperCase()
        : 'F';

    return SizedBox(
      height: _s(context, 68),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: _s(context, 12),
        ),
        child: Row(
          children: [
            // PROFILE AVATAR
            GestureDetector(
              onTap: () {
                _openProfile(context);
              },
              child: Container(
                width: _s(context, 30),
                height: _s(context, 30),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white
                      .withValues(alpha: 0.18),
                  border: Border.all(
                    color: Colors.white
                        .withValues(alpha: 0.55),
                    width: 1.2,
                  ),
                ),
                child: Center(
                  child: Text(
                    initial,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: _s(context, 11),
                      fontWeight:
                      FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),

            SizedBox(
              width: _s(context, 10),
            ),

            // GREETING
            Expanded(
              child: Column(
                mainAxisAlignment:
                MainAxisAlignment.center,
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hi, $displayName 👋',
                    maxLines: 1,
                    overflow:
                    TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize:
                      _s(context, 10),
                      fontWeight:
                      FontWeight.w700,
                      height: 1.0,
                    ),
                  ),

                  SizedBox(
                    height: _s(context, 3),
                  ),

                  Text(
                    'Keep going, stay healthy!',
                    maxLines: 1,
                    overflow:
                    TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white
                          .withValues(alpha: 0.78),
                      fontSize:
                      _s(context, 6.5),
                      fontWeight:
                      FontWeight.w400,
                      height: 1.0,
                    ),
                  ),
                ],
              ),
            ),

            // ADD BUTTON
            GestureDetector(
              onTap: () {
                _showAddOptions(context);
              },
              child: Container(
                width: _s(context, 28),
                height: _s(context, 28),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white
                      .withValues(alpha: 0.16),
                ),
                child: Icon(
                  Icons.add_rounded,
                  color: Colors.white,
                  size: _s(context, 17),
                ),
              ),
            ),

            SizedBox(
              width: _s(context, 7),
            ),

            // NOTIFICATION
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: _s(context, 28),
                  height: _s(context, 28),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white
                        .withValues(alpha: 0.16),
                  ),
                  child: Icon(
                    Icons
                        .notifications_none_rounded,
                    color: Colors.white,
                    size: _s(context, 16),
                  ),
                ),

                Positioned(
                  top: _s(context, 5),
                  right: _s(context, 5),
                  child: Container(
                    width: _s(context, 6),
                    height: _s(context, 6),
                    decoration:
                    const BoxDecoration(
                      shape: BoxShape.circle,
                      color:
                      Color(0xFFFF5A5A),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ===============================================================
  // TODAY SUMMARY
  // ===============================================================

  Widget _buildTodaySummary(
      BuildContext context, {
        required int totalSteps,
      }) {
    final progress =
    (totalSteps / 10000).clamp(
      0.0,
      1.0,
    );

    final percentage =
    (progress * 100).round();

    return Container(
      height: _s(context, 97),
      padding: EdgeInsets.symmetric(
        horizontal: _s(context, 9),
        vertical: _s(context, 8),
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
        BorderRadius.circular(
          _s(context, 9),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black
                .withValues(alpha: 0.045),
            blurRadius:
            _s(context, 10),
            offset:
            Offset(0, _s(context, 3)),
          ),
        ],
      ),
      child: Column(
        children: [
          SizedBox(
            height: _s(context, 16),
            child: Row(
              children: [
                Text(
                  "Today's Summary",
                  style: TextStyle(
                    color:
                    AppColors.normalText,
                    fontSize:
                    _s(context, 7.5),
                    fontWeight:
                    FontWeight.w700,
                    height: 1.0,
                  ),
                ),

                const Spacer(),

                Text(
                  _todayDate(),
                  style: TextStyle(
                    color:
                    AppColors.secondaryText,
                    fontSize:
                    _s(context, 5.8),
                    fontWeight:
                    FontWeight.w500,
                    height: 1.0,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(
            height: _s(context, 3),
          ),

          Expanded(
            child: Row(
              children: [
                SizedBox(
                  width: _s(context, 52),
                  height: _s(context, 52),
                  child: Stack(
                    alignment:
                    Alignment.center,
                    children: [
                      SizedBox(
                        width:
                        _s(context, 48),
                        height:
                        _s(context, 48),
                        child:
                        CircularProgressIndicator(
                          value: progress,
                          strokeWidth:
                          _s(context, 2.7),
                          backgroundColor:
                          AppColors
                              .primaryBlue
                              .withValues(
                            alpha: 0.13,
                          ),
                          valueColor:
                          const AlwaysStoppedAnimation<
                              Color>(
                            AppColors
                                .primaryBlue,
                          ),
                        ),
                      ),

                      Icon(
                        Icons
                            .directions_run_rounded,
                        color:
                        AppColors.normalText,
                        size:
                        _s(context, 25),
                      ),
                    ],
                  ),
                ),

                SizedBox(
                  width: _s(context, 8),
                ),

                Expanded(
                  child: Column(
                    mainAxisAlignment:
                    MainAxisAlignment
                        .center,
                    crossAxisAlignment:
                    CrossAxisAlignment
                        .start,
                    children: [
                      Text(
                        _formatNumber(
                          totalSteps,
                        ),
                        maxLines: 1,
                        overflow:
                        TextOverflow.ellipsis,
                        style: TextStyle(
                          color: AppColors
                              .primaryBlue,
                          fontSize:
                          _s(context, 16),
                          fontWeight:
                          FontWeight.w800,
                          height: 1.0,
                        ),
                      ),

                      SizedBox(
                        height: _s(context, 3),
                      ),

                      Text(
                        'Steps',
                        style: TextStyle(
                          color: AppColors
                              .normalText,
                          fontSize:
                          _s(context, 7),
                          fontWeight:
                          FontWeight.w500,
                          height: 1.0,
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(
                  width: _s(context, 42),
                  height: _s(context, 42),
                  child: Stack(
                    alignment:
                    Alignment.center,
                    children: [
                      SizedBox(
                        width:
                        _s(context, 39),
                        height:
                        _s(context, 39),
                        child:
                        CircularProgressIndicator(
                          value: progress,
                          strokeWidth:
                          _s(context, 2.5),
                          backgroundColor:
                          AppColors
                              .primaryBlue
                              .withValues(
                            alpha: 0.13,
                          ),
                          valueColor:
                          const AlwaysStoppedAnimation<
                              Color>(
                            AppColors
                                .primaryBlue,
                          ),
                        ),
                      ),

                      Text(
                        '$percentage%',
                        style: TextStyle(
                          color: AppColors
                              .normalText,
                          fontSize:
                          _s(context, 7),
                          fontWeight:
                          FontWeight.w700,
                          height: 1.0,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ===============================================================
  // STATS
  // ===============================================================

  Widget _buildStatsRow(
      BuildContext context, {
        required int calories,
        required int workouts,
        required double distance,
      }) {
    return Row(
      children: [
        Expanded(
          child: _smallStatCard(
            context,
            icon:
            Icons.local_fire_department_rounded,
            iconColor: Colors.red,
            value: '$calories',
            label: 'Calories',
          ),
        ),

        SizedBox(
          width: _s(context, 4),
        ),

        Expanded(
          child: _smallStatCard(
            context,
            icon:
            Icons.access_time_rounded,
            iconColor:
            AppColors.primaryBlue,
            value: '$workouts',
            label: 'Workout (min)',
          ),
        ),

        SizedBox(
          width: _s(context, 4),
        ),

        Expanded(
          child: _smallStatCard(
            context,
            icon:
            Icons.location_on_rounded,
            iconColor: Colors.green,
            value:
            distance.toStringAsFixed(1),
            label: 'Distance (km)',
          ),
        ),
      ],
    );
  }

  Widget _smallStatCard(
      BuildContext context, {
        required IconData icon,
        required Color iconColor,
        required String value,
        required String label,
      }) {
    return Container(
      height: _s(context, 73),
      padding: EdgeInsets.symmetric(
        horizontal: _s(context, 3),
        vertical: _s(context, 5),
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
        BorderRadius.circular(
          _s(context, 8),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black
                .withValues(alpha: 0.035),
            blurRadius: _s(context, 3),
            offset:
            Offset(0, _s(context, 1)),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment:
        MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: iconColor,
            size: _s(context, 17),
          ),

          SizedBox(
            height: _s(context, 3),
          ),

          Text(
            value,
            maxLines: 1,
            overflow:
            TextOverflow.ellipsis,
            style: TextStyle(
              color:
              AppColors.normalText,
              fontSize:
              _s(context, 9),
              fontWeight:
              FontWeight.w800,
              height: 1.0,
            ),
          ),

          SizedBox(
            height: _s(context, 3),
          ),

          Text(
            label,
            maxLines: 1,
            overflow:
            TextOverflow.ellipsis,
            textAlign:
            TextAlign.center,
            style: TextStyle(
              color:
              AppColors.secondaryText,
              fontSize:
              _s(context, 5.5),
              fontWeight:
              FontWeight.w500,
              height: 1.0,
            ),
          ),
        ],
      ),
    );
  }

  // ===============================================================
  // WEEKLY PROGRESS
  // ===============================================================

  Widget _buildWeeklyCard(
      BuildContext context,
      List<Activity> activities,
      ) {
    final now = DateTime.now();

    final weeklyData = List.generate(
      7,
          (index) {
        final date = now.subtract(
          Duration(days: 6 - index),
        );

        return activities
            .where(
              (activity) =>
          activity.date.year ==
              date.year &&
              activity.date.month ==
                  date.month &&
              activity.date.day ==
                  date.day,
        )
            .fold<int>(
          0,
              (sum, activity) =>
          sum + activity.calories,
        );
      },
    );

    final maxValue =
    weeklyData.fold<int>(
      0,
          (max, value) =>
      value > max ? value : max,
    );

    return Container(
      height: _s(context, 96),
      padding: EdgeInsets.fromLTRB(
        _s(context, 9),
        _s(context, 7),
        _s(context, 9),
        _s(context, 5),
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
        BorderRadius.circular(
          _s(context, 8),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black
                .withValues(alpha: 0.045),
            blurRadius:
            _s(context, 10),
            offset:
            Offset(0, _s(context, 3)),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Weekly Progress (Calories Burned)',
                  maxLines: 1,
                  overflow:
                  TextOverflow.ellipsis,
                  style: TextStyle(
                    color:
                    AppColors.normalText,
                    fontSize:
                    _s(context, 7),
                    fontWeight:
                    FontWeight.w700,
                    height: 1.0,
                  ),
                ),
              ),

              Text(
                'kcal',
                style: TextStyle(
                  color:
                  AppColors.secondaryText,
                  fontSize:
                  _s(context, 5.5),
                  fontWeight:
                  FontWeight.w600,
                  height: 1.0,
                ),
              ),
            ],
          ),

          SizedBox(
            height: _s(context, 5),
          ),

          Expanded(
            child: Row(
              crossAxisAlignment:
              CrossAxisAlignment.end,
              children: [
                SizedBox(
                  width:
                  _s(context, 15),
                  child: Column(
                    mainAxisAlignment:
                    MainAxisAlignment
                        .spaceBetween,
                    crossAxisAlignment:
                    CrossAxisAlignment
                        .start,
                    children: [
                      _chartLabel(
                        context,
                        '600',
                      ),
                      _chartLabel(
                        context,
                        '400',
                      ),
                      _chartLabel(
                        context,
                        '200',
                      ),
                      _chartLabel(
                        context,
                        '0',
                      ),
                    ],
                  ),
                ),

                SizedBox(
                  width: _s(context, 2),
                ),

                Expanded(
                  child: Row(
                    crossAxisAlignment:
                    CrossAxisAlignment.end,
                    mainAxisAlignment:
                    MainAxisAlignment
                        .spaceAround,
                    children:
                    List.generate(
                      7,
                          (index) {
                        final value =
                        weeklyData[index];

                        final barHeight =
                        maxValue == 0
                            ? _s(context, 5)
                            : ((value /
                            maxValue) *
                            _s(context, 42))
                            .clamp(
                          _s(context, 5),
                          _s(context, 42),
                        );

                        final date =
                        now.subtract(
                          Duration(
                            days: 6 - index,
                          ),
                        );

                        final isToday =
                            index == 6;

                        return Expanded(
                          child: Column(
                            mainAxisAlignment:
                            MainAxisAlignment
                                .end,
                            children: [
                              Container(
                                width:
                                _s(context, 5),
                                height:
                                barHeight,
                                decoration:
                                BoxDecoration(
                                  color: isToday
                                      ? AppColors
                                      .primaryBlue
                                      .withValues(
                                    alpha:
                                    0.55,
                                  )
                                      : AppColors
                                      .primaryBlue,
                                  borderRadius:
                                  BorderRadius
                                      .circular(
                                    _s(context, 4),
                                  ),
                                ),
                              ),

                              SizedBox(
                                height:
                                _s(context, 4),
                              ),

                              Text(
                                _dayName(
                                  date.weekday,
                                ),
                                style: TextStyle(
                                  color: AppColors
                                      .secondaryText,
                                  fontSize:
                                  _s(context, 5),
                                  fontWeight:
                                  FontWeight.w500,
                                  height: 1.0,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _chartLabel(
      BuildContext context,
      String value,
      ) {
    return Text(
      value,
      style: TextStyle(
        color:
        AppColors.secondaryText,
        fontSize: _s(context, 4.5),
        height: 1.0,
      ),
    );
  }

  // ===============================================================
  // RECENT ACTIVITIES
  // ===============================================================

  Widget _buildRecentActivities(
      BuildContext context,
      List<Activity> activities,
      ) {
    final recent =
    activities.take(1).toList();

    return Container(
      height: _s(context, 78),
      padding: EdgeInsets.fromLTRB(
        _s(context, 9),
        _s(context, 7),
        _s(context, 9),
        _s(context, 6),
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
        BorderRadius.circular(
          _s(context, 8),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black
                .withValues(alpha: 0.045),
            blurRadius:
            _s(context, 10),
            offset:
            Offset(0, _s(context, 3)),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Recent Activities',
                  style: TextStyle(
                    color:
                    AppColors.normalText,
                    fontSize:
                    _s(context, 7),
                    fontWeight:
                    FontWeight.w700,
                    height: 1.0,
                  ),
                ),
              ),

              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                      const HistoryScreen(),
                    ),
                  );
                },
                child: Text(
                  'See All',
                  style: TextStyle(
                    color:
                    AppColors.primaryBlue,
                    fontSize:
                    _s(context, 5.5),
                    fontWeight:
                    FontWeight.w700,
                    height: 1.0,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(
            height: _s(context, 4),
          ),

          if (recent.isEmpty)
            Expanded(
              child: Center(
                child: Text(
                  'No activities recorded yet',
                  style: TextStyle(
                    color:
                    AppColors.secondaryText,
                    fontSize:
                    _s(context, 6),
                  ),
                ),
              ),
            )
          else
            Expanded(
              child: _recentActivityItem(
                context,
                recent.first,
              ),
            ),
        ],
      ),
    );
  }

  Widget _recentActivityItem(
      BuildContext context,
      Activity activity,
      ) {
    final iconColor =
    _activityColor(activity.type);

    return Row(
      children: [
        Container(
          width: _s(context, 30),
          height: _s(context, 30),
          decoration: BoxDecoration(
            color: iconColor
                .withValues(alpha: 0.12),
            borderRadius:
            BorderRadius.circular(
              _s(context, 9),
            ),
          ),
          child: Icon(
            _activityIcon(activity.type),
            color: iconColor,
            size: _s(context, 15),
          ),
        ),

        SizedBox(
          width: _s(context, 7),
        ),

        Expanded(
          child: Column(
            mainAxisAlignment:
            MainAxisAlignment.center,
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              Text(
                activity.title,
                maxLines: 1,
                overflow:
                TextOverflow.ellipsis,
                style: TextStyle(
                  color:
                  AppColors.normalText,
                  fontSize:
                  _s(context, 7),
                  fontWeight:
                  FontWeight.w700,
                  height: 1.0,
                ),
              ),

              SizedBox(
                height: _s(context, 2),
              ),

              Text(
                '${activity.durationMinutes} min • ${activity.calories} kcal',
                maxLines: 1,
                overflow:
                TextOverflow.ellipsis,
                style: TextStyle(
                  color: AppColors
                      .secondaryText,
                  fontSize:
                  _s(context, 5),
                  height: 1.0,
                ),
              ),
            ],
          ),
        ),

        SizedBox(
          width: _s(context, 5),
        ),

        Text(
          _formatTime(activity.date),
          maxLines: 1,
          style: TextStyle(
            color:
            AppColors.secondaryText,
            fontSize:
            _s(context, 5),
            fontWeight:
            FontWeight.w500,
            height: 1.0,
          ),
        ),
      ],
    );
  }

  // ===============================================================
  // BOTTOM NAVIGATION
  // ===============================================================

  Widget _buildBottomNavigationBar(
      BuildContext context,
      ) {
    final bottomInset =
        MediaQuery.paddingOf(context).bottom;

    final navHeight =
    _s(context, 43);

    return Container(
      height: navHeight + bottomInset,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft:
          Radius.circular(
            _s(context, 18),
          ),
          topRight:
          Radius.circular(
            _s(context, 18),
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black
                .withValues(alpha: 0.06),
            blurRadius:
            _s(context, 14),
            offset:
            Offset(0, _s(context, -3)),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.only(
          bottom: bottomInset,
        ),
        child: SizedBox(
          height: navHeight,
          child: Row(
            children: [
              // HOME
              _navItem(
                context,
                icon: Icons.home_rounded,
                label: 'Home',
                index: 0,
                onTap: () {
                  setState(() {
                    _selectedIndex = 0;
                  });
                },
              ),

              // EXERCISE
              _navItem(
                context,
                icon:
                Icons.fitness_center_rounded,
                label: 'Exercise',
                index: 1,
                onTap: () {
                  _openExercise(context);
                },
              ),

              // DIET
              _navItem(
                context,
                icon:
                Icons.restaurant_rounded,
                label: 'Diet',
                index: 2,
                onTap: () {
                  _openDiet(context);
                },
              ),

              // WATER
              _navItem(
                context,
                icon:
                Icons.water_drop_rounded,
                label: 'Water',
                index: 3,
                onTap: () {
                  _openWater(context);
                },
              ),

              // PROFILE
              _navItem(
                context,
                icon:
                Icons.person_outline_rounded,
                label: 'Profile',
                index: 4,
                onTap: () {
                  _openProfile(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navItem(
      BuildContext context, {
        required IconData icon,
        required String label,
        required int index,
        required VoidCallback onTap,
      }) {
    final isActive =
        _selectedIndex == index;

    return Expanded(
      child: InkWell(
        onTap: onTap,
        splashColor:
        AppColors.primaryBlue
            .withValues(alpha: 0.08),
        highlightColor:
        Colors.transparent,
        child: Column(
          mainAxisAlignment:
          MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration:
              const Duration(
                milliseconds: 180,
              ),
              padding:
              EdgeInsets.symmetric(
                horizontal:
                _s(context, 8),
                vertical:
                _s(context, 3),
              ),
              decoration:
              BoxDecoration(
                color: isActive
                    ? AppColors.primaryBlue
                    .withValues(
                  alpha: 0.10,
                )
                    : Colors.transparent,
                borderRadius:
                BorderRadius.circular(
                  _s(context, 12),
                ),
              ),
              child: Icon(
                icon,
                size: _s(context, 15),
                color: isActive
                    ? AppColors.primaryBlue
                    : AppColors
                    .secondaryText,
              ),
            ),

            SizedBox(
              height: _s(context, 1),
            ),

            Text(
              label,
              maxLines: 1,
              style: TextStyle(
                color: isActive
                    ? AppColors.primaryBlue
                    : AppColors
                    .secondaryText,
                fontSize:
                _s(context, 5.2),
                fontWeight: isActive
                    ? FontWeight.w700
                    : FontWeight.w500,
                height: 1.0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===============================================================
  // CALCULATIONS
  // ===============================================================

  List<Activity> _todayActivities(
      List<Activity> activities,
      ) {
    final now = DateTime.now();

    return activities.where((activity) {
      return activity.date.year ==
          now.year &&
          activity.date.month ==
              now.month &&
          activity.date.day ==
              now.day;
    }).toList();
  }

  int _totalSteps(
      List<Activity> activities,
      ) {
    return activities.fold(
      0,
          (sum, activity) =>
      sum + activity.steps,
    );
  }

  int _totalCalories(
      List<Activity> activities,
      ) {
    return activities.fold(
      0,
          (sum, activity) =>
      sum + activity.calories,
    );
  }

  double _totalDistance(
      List<Activity> activities,
      ) {
    return activities.fold(
      0.0,
          (sum, activity) =>
      sum + activity.distance,
    );
  }

  int _workoutCount(
      List<Activity> activities,
      ) {
    return activities
        .where(
          (activity) =>
      activity.type
          .toLowerCase() ==
          'workout' ||
          activity.type
              .toLowerCase() ==
              'running' ||
          activity.type
              .toLowerCase() ==
              'cycling',
    )
        .fold<int>(
      0,
          (sum, activity) =>
      sum +
          activity.durationMinutes,
    );
  }

  // ===============================================================
  // HELPERS
  // ===============================================================

  String _formatNumber(int number) {
    return number.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
          (match) => '${match[1]},',
    );
  }

  String _todayDate() {
    final now = DateTime.now();

    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return '${now.day.toString().padLeft(2, '0')} '
        '${months[now.month - 1]} '
        '${now.year}';
  }

  String _dayName(int weekday) {
    const days = [
      'Mon',
      'Tue',
      'Wed',
      'Thu',
      'Fri',
      'Sat',
      'Sun',
    ];

    return days[weekday - 1];
  }

  IconData _activityIcon(String type) {
    switch (type.toLowerCase()) {
      case 'walking':
        return Icons.directions_walk_rounded;

      case 'running':
        return Icons.directions_run_rounded;

      case 'cycling':
        return Icons.directions_bike_rounded;

      case 'workout':
      default:
        return Icons.fitness_center_rounded;
    }
  }

  Color _activityColor(String type) {
    switch (type.toLowerCase()) {
      case 'running':
      case 'run':
        return AppColors.primaryBlue;

      case 'cycling':
      case 'bike':
        return Colors.green;

      case 'walking':
      case 'walk':
        return Colors.orange;

      case 'swimming':
      case 'swim':
        return Colors.cyan;

      default:
        return AppColors.primaryBlue;
    }
  }

  String _formatTime(DateTime date) {
    final hour24 = date.hour;
    final minute =
    date.minute.toString().padLeft(2, '0');

    final period =
    hour24 >= 12 ? 'PM' : 'AM';

    final hour12 =
    hour24 % 12 == 0
        ? 12
        : hour24 % 12;

    return '$hour12:$minute $period';
  }
}

// ============================================================================
// ADD OPTION TILE
// ============================================================================

class _AddOptionTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _AddOptionTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius:
      BorderRadius.circular(14),
      child: Container(
        padding:
        const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: iconColor
              .withValues(alpha: 0.06),
          borderRadius:
          BorderRadius.circular(14),
          border: Border.all(
            color: iconColor
                .withValues(alpha: 0.18),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              alignment:
              Alignment.center,
              decoration:
              BoxDecoration(
                color: iconColor
                    .withValues(alpha: 0.14),
                borderRadius:
                BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: 24,
              ),
            ),

            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment
                    .start,
                children: [
                  Text(
                    title,
                    style:
                    const TextStyle(
                      color:
                      AppColors.normalText,
                      fontSize: 14.5,
                      fontWeight:
                      FontWeight.w700,
                    ),
                  ),

                  const SizedBox(
                    height: 3,
                  ),

                  Text(
                    subtitle,
                    style:
                    const TextStyle(
                      color:
                      AppColors.secondaryText,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

            const Icon(
              Icons.chevron_right_rounded,
              color:
              AppColors.secondaryText,
            ),
          ],
        ),
      ),
    );
  }
}