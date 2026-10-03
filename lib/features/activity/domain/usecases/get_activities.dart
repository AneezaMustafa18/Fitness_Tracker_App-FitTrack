import '../entities/activity.dart';
import '../repositories/activity_repository.dart';

class GetActivities {
  final ActivityRepository repository;

  GetActivities({
    required this.repository,
  });

  Stream<List<Activity>> call() {
    return repository.getActivities();
  }
}