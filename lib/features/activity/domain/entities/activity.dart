class Activity {
  final String id;
  final String title;
  final String type;
  final DateTime date;
  final int steps;
  final int calories;
  final int durationMinutes;
  final double distance;

  const Activity({
    required this.id,
    required this.title,
    required this.type,
    required this.date,
    required this.steps,
    required this.calories,
    required this.durationMinutes,
    required this.distance,
  });
}