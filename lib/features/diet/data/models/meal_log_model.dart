import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/meal_log.dart';

class MealLogModel extends MealLog {
  const MealLogModel({
    required super.id,
    required super.name,
    required super.mealType,
    required super.calories,
    required super.protein,
    required super.carbs,
    required super.fat,
    required super.date,
  });

  factory MealLogModel.fromMap(Map<String, dynamic> map, String id) {
    final timestamp = map['date'];

    return MealLogModel(
      id: id,
      name: map['name'] as String? ?? '',
      mealType: map['mealType'] as String? ?? 'Snack',
      calories: (map['calories'] as num?)?.toInt() ?? 0,
      protein: (map['protein'] as num?)?.toDouble() ?? 0.0,
      carbs: (map['carbs'] as num?)?.toDouble() ?? 0.0,
      fat: (map['fat'] as num?)?.toDouble() ?? 0.0,
      date: timestamp is Timestamp
          ? timestamp.toDate()
          : timestamp is DateTime
          ? timestamp
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'mealType': mealType,
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
      'date': Timestamp.fromDate(date),
    };
  }
}
