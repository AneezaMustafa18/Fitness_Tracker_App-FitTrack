import '../../domain/entities/activity.dart';
import '../../domain/repositories/activity_repository.dart';
import '../datasources/activity_remote_data_source.dart';
import '../models/activity_model.dart';

class ActivityRepositoryImpl
    implements ActivityRepository {
  final ActivityRemoteDataSource remoteDataSource;

  ActivityRepositoryImpl({
    required this.remoteDataSource,
  });

  @override
  Future<Activity> addActivity(
      Activity activity,
      ) async {
    final model = ActivityModel(
      id: activity.id,
      title: activity.title,
      type: activity.type,
      date: activity.date,
      steps: activity.steps,
      calories: activity.calories,
      durationMinutes: activity.durationMinutes,
      distance: activity.distance,
    );

    final documentId =
    await remoteDataSource.addActivity(model);

    return ActivityModel(
      id: documentId,
      title: model.title,
      type: model.type,
      date: model.date,
      steps: model.steps,
      calories: model.calories,
      durationMinutes: model.durationMinutes,
      distance: model.distance,
    );
  }

  @override
  Stream<List<Activity>> getActivities() {
    return remoteDataSource.getActivities();
  }

  @override
  Future<void> deleteActivity(
      String activityId,
      ) {
    return remoteDataSource.deleteActivity(
      activityId,
    );
  }
}