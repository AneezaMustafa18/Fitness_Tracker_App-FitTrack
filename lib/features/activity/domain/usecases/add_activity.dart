import '../entities/activity.dart';
import '../repositories/activity_repository.dart';

class AddActivity {
  final ActivityRepository repository;

  AddActivity({
    required this.repository,
  });

  Future<Activity> call(
      Activity activity,
      ) {
    return repository.addActivity(activity);
  }
}