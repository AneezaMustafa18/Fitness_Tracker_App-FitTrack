import '../repositories/activity_repository.dart';

class DeleteActivity {
  final ActivityRepository repository;

  DeleteActivity({
    required this.repository,
  });

  Future<void> call(
      String activityId,
      ) {
    return repository.deleteActivity(
      activityId,
    );
  }
}