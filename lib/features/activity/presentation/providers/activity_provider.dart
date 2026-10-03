import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../domain/entities/activity.dart';
import '../../domain/usecases/add_activity.dart';
import '../../domain/usecases/delete_activity.dart';
import '../../domain/usecases/get_activities.dart';

class ActivityProvider extends ChangeNotifier {
  final AddActivity addActivity;
  final GetActivities getActivities;
  final DeleteActivity deleteActivity;

  ActivityProvider({
    required this.addActivity,
    required this.getActivities,
    required this.deleteActivity,
  });

  List<Activity> _activities = [];

  bool _isLoading = false;
  String? _errorMessage;

  StreamSubscription<List<Activity>>? _activitiesSubscription;

  List<Activity> get activities => List.unmodifiable(_activities);

  bool get isLoading => _isLoading;

  String? get errorMessage => _errorMessage;

  // ============================================================
  // START FIRESTORE LISTENER
  // ============================================================

  void startListening() {
    // Don't create duplicate listeners.
    if (_activitiesSubscription != null) {
      return;
    }

    _isLoading = true;
    _errorMessage = null;

    notifyListeners();

    _activitiesSubscription = getActivities().listen(
          (activities) {
        _activities = activities;

        _isLoading = false;
        _errorMessage = null;

        notifyListeners();
      },
      onError: (error) {
        _isLoading = false;
        _errorMessage = _cleanError(error);

        _activitiesSubscription = null;

        notifyListeners();
      },
      cancelOnError: false,
    );
  }

  // ============================================================
  // CREATE ACTIVITY
  // ============================================================

  Future<Activity> createActivity(
      Activity activity,
      ) async {
    _isLoading = true;
    _errorMessage = null;

    notifyListeners();

    try {
      final createdActivity = await addActivity(activity);

      _isLoading = false;
      _errorMessage = null;

      // Normally Firestore snapshot will update the list.
      // We also update local state immediately so UI feels instant.
      final alreadyExists = _activities.any(
            (item) => item.id == createdActivity.id,
      );

      if (!alreadyExists) {
        _activities = [
          createdActivity,
          ..._activities,
        ];
      }

      notifyListeners();

      return createdActivity;
    } catch (error) {
      _isLoading = false;
      _errorMessage = _cleanError(error);

      notifyListeners();

      rethrow;
    }
  }

  // ============================================================
  // DELETE ACTIVITY
  // ============================================================

  Future<void> removeActivity(
      String activityId,
      ) async {
    if (activityId.trim().isEmpty) {
      throw Exception('Invalid activity ID.');
    }

    _isLoading = true;
    _errorMessage = null;

    notifyListeners();

    try {
      // First delete from Firestore.
      await deleteActivity(activityId);

      // Immediately update local UI.
      _activities = _activities
          .where(
            (activity) => activity.id != activityId,
      )
          .toList();

      _isLoading = false;
      _errorMessage = null;

      notifyListeners();
    } catch (error) {
      _isLoading = false;
      _errorMessage = _cleanError(error);

      notifyListeners();

      rethrow;
    }
  }

  // ============================================================
  // MANUAL REFRESH
  // ============================================================

  Future<void> refresh() async {
    _errorMessage = null;

    // Firestore snapshots are already real-time.
    // If listener is not active, start it.
    if (_activitiesSubscription == null) {
      startListening();
      return;
    }

    // Give Firestore listener a moment to deliver the latest
    // snapshot instead of creating another subscription.
    notifyListeners();
  }

  // ============================================================
  // CLEAR ERROR
  // ============================================================

  void clearError() {
    if (_errorMessage == null) {
      return;
    }

    _errorMessage = null;
    notifyListeners();
  }

  // ============================================================
  // ERROR CLEANUP
  // ============================================================

  String _cleanError(Object error) {
    final message = error.toString();

    if (message.startsWith('Exception: ')) {
      return message.substring('Exception: '.length);
    }

    return message;
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    _activitiesSubscription?.cancel();
    _activitiesSubscription = null;

    super.dispose();
  }
}