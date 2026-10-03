import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../data/datasources/water_remote_data_source.dart';
import '../../data/models/water_log_model.dart';
import '../../domain/entities/water_log.dart';

/// Default daily water goal used until the user sets a custom one.
const int kDefaultWaterGoalMl = 2000; // ~ 8 glasses (250ml each)

class WaterProvider extends ChangeNotifier {
  final WaterRemoteDataSource dataSource;

  WaterProvider({required this.dataSource});

  List<WaterLog> _todayLogs = [];
  int? _customGoalMl;
  bool _isLoading = false;
  String? _errorMessage;

  StreamSubscription<List<WaterLogModel>>? _logsSub;
  StreamSubscription<int?>? _goalSub;

  List<WaterLog> get todayLogs => List.unmodifiable(_todayLogs);

  bool get isLoading => _isLoading;

  String? get errorMessage => _errorMessage;

  int get goalMl => _customGoalMl ?? kDefaultWaterGoalMl;

  int get totalMl => _todayLogs.fold(0, (sum, log) => sum + log.amountMl);

  double get progress => goalMl == 0 ? 0 : (totalMl / goalMl).clamp(0.0, 1.0);

  int get glassesConsumed => (totalMl / 250).round();

  int get glassGoal => (goalMl / 250).round();

  void startListening() {
    if (_logsSub != null) return;

    _isLoading = true;
    notifyListeners();

    _logsSub = dataSource.getTodayLogs().listen((logs) {
      _todayLogs = logs;
      _isLoading = false;
      _errorMessage = null;
      notifyListeners();
    }, onError: (error) {
      _isLoading = false;
      _errorMessage = error.toString();
      _logsSub = null;
      notifyListeners();
    });

    _goalSub = dataSource.getGoalMl().listen((goal) {
      _customGoalMl = goal;
      notifyListeners();
    });
  }

  Future<void> addWater(int amountMl) async {
    try {
      final log = WaterLogModel(id: '', amountMl: amountMl, date: DateTime.now());
      await dataSource.addWaterLog(log);
    } catch (error) {
      _errorMessage = error.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> removeLog(String logId) async {
    await dataSource.deleteWaterLog(logId);
  }

  Future<void> setGoalMl(int goalMl) async {
    await dataSource.setGoalMl(goalMl);
    _customGoalMl = goalMl;
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
