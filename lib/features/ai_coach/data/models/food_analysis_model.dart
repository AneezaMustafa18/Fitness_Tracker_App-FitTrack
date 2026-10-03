import '../../domain/entities/food_analysis.dart';

class FoodAnalysisModel extends FoodAnalysis {
  const FoodAnalysisModel({
    required super.foods,
  });

  factory FoodAnalysisModel.fromJson(Map<String, dynamic> json) {
    final foodsJson = json['foods'];

    if (foodsJson is! List) {
      return const FoodAnalysisModel(
        foods: [],
      );
    }

    final foods = foodsJson
        .whereType<Map<String, dynamic>>()
        .map(
          (food) => FoodItemModel.fromJson(food),
    )
        .toList();

    return FoodAnalysisModel(
      foods: foods,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'foods': foods
          .map(
            (food) => {
          'food_name': food.foodName,
          'serving_size': food.servingSize,
          'calories': food.calories,
          'protein': food.protein,
          'carbohydrates': food.carbohydrates,
          'fat': food.fat,
          'fiber': food.fiber,
          'confidence': food.confidence,
        },
      )
          .toList(),
    };
  }
}

class FoodItemModel extends FoodItem {
  const FoodItemModel({
    required super.foodName,
    required super.servingSize,
    required super.calories,
    required super.protein,
    required super.carbohydrates,
    required super.fat,
    required super.fiber,
    required super.confidence,
  });

  factory FoodItemModel.fromJson(Map<String, dynamic> json) {
    return FoodItemModel(
      foodName: json['food_name']?.toString() ?? 'Unknown food',
      servingSize: json['serving_size']?.toString() ?? 'Unknown serving',
      calories: _toInt(json['calories']),
      protein: _toDouble(json['protein']),
      carbohydrates: _toDouble(json['carbohydrates']),
      fat: _toDouble(json['fat']),
      fiber: _toDouble(json['fiber']),
      confidence: _toDouble(json['confidence']),
    );
  }

  static int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.round();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static double _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0.0;
  }
}