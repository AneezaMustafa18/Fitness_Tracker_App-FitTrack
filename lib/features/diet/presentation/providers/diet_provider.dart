import 'dart:async';

import 'package:fitness_tracker_app/features/diet/data/datasources/diet_remote_data_resource.dart' show DietRemoteDataSource;
import 'package:flutter/foundation.dart';


import '../../data/models/meal_log_model.dart';
import '../../domain/entities/meal_log.dart';

/// Default daily calorie goal used until the user sets a custom one.
const int kDefaultCalorieGoal = 2000;

class DietProvider extends ChangeNotifier {
  final DietRemoteDataSource dataSource;

  DietProvider({required this.dataSource});

  List<MealLog> _todayMeals = [];
  int? _customCalorieGoal;
  bool _isLoading = false;
  String? _errorMessage;

  StreamSubscription<List<MealLogModel>>? _logsSub;
  StreamSubscription<int?>? _goalSub;

  List<MealLog> get todayMeals => List.unmodifiable(_todayMeals);

  bool get isLoading => _isLoading;

  String? get errorMessage => _errorMessage;

  int get calorieGoal => _customCalorieGoal ?? kDefaultCalorieGoal;

  int get totalCalories => _todayMeals.fold(0, (sum, m) => sum + m.calories);

  double get totalProtein => _todayMeals.fold(0.0, (sum, m) => sum + m.protein);

  double get totalCarbs => _todayMeals.fold(0.0, (sum, m) => sum + m.carbs);

  double get totalFat => _todayMeals.fold(0.0, (sum, m) => sum + m.fat);

  double get progress => calorieGoal == 0 ? 0 : (totalCalories / calorieGoal).clamp(0.0, 1.0);

  void startListening() {
    if (_logsSub != null) return;

    _isLoading = true;
    notifyListeners();

    _logsSub = dataSource.getTodayLogs().listen((logs) {
      _todayMeals = logs;
      _isLoading = false;
      _errorMessage = null;
      notifyListeners();
    }, onError: (error) {
      _isLoading = false;
      _errorMessage = error.toString();
      _logsSub = null;
      notifyListeners();
    });

    _goalSub = dataSource.getCalorieGoal().listen((goal) {
      _customCalorieGoal = goal;
      notifyListeners();
    });
  }

  Future<void> addMeal({
    required String name,
    required String mealType,
    required int calories,
    required double protein,
    required double carbs,
    required double fat,
  }) async {
    try {
      final log = MealLogModel(
        id: '',
        name: name,
        mealType: mealType,
        calories: calories,
        protein: protein,
        carbs: carbs,
        fat: fat,
        date: DateTime.now(),
      );
      await dataSource.addMealLog(log);
    } catch (error) {
      _errorMessage = error.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> removeMeal(String logId) async {
    await dataSource.deleteMealLog(logId);
  }

  Future<void> setCalorieGoal(int goal) async {
    await dataSource.setCalorieGoal(goal);
    _customCalorieGoal = goal;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _logsSub?.cancel();
    _goalSub?.cancel();
    super.dispose();
  }
}
