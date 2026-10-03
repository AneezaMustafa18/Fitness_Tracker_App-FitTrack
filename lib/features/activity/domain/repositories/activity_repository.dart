import '../entities/activity.dart';

abstract class ActivityRepository {
  Future<Activity> addActivity(
      Activity activity,
      );

  Stream<List<Activity>> getActivities();

  Future<void> deleteActivity(
      String activityId,
      );
}