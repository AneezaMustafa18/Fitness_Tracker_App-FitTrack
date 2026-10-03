import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/activity.dart';

class ActivityModel extends Activity {
  const ActivityModel({
    required super.id,
    required super.title,
    required super.type,
    required super.date,
    required super.steps,
    required super.calories,
    required super.durationMinutes,
    required super.distance,
  });

  factory ActivityModel.fromMap(
      Map<String, dynamic> map,
      String id,
      ) {
    final timestamp = map['date'];

    return ActivityModel(
      id: id,
      title: map['title'] as String? ?? '',
      type: map['type'] as String? ?? '',
      date: timestamp is Timestamp
          ? timestamp.toDate()
          : timestamp is DateTime
          ? timestamp
          : DateTime.now(),
      steps: (map['steps'] as num?)?.toInt() ?? 0,
      calories: (map['calories'] as num?)?.toInt() ?? 0,
      durationMinutes:
      (map['durationMinutes'] as num?)?.toInt() ?? 0,
      distance:
      (map['distance'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'type': type,
      'date': Timestamp.fromDate(date),
      'steps': steps,
      'calories': calories,
      'durationMinutes': durationMinutes,
      'distance': distance,
    };
  }
}