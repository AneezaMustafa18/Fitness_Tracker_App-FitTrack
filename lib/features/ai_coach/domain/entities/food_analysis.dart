class FoodAnalysis {
  final List<FoodItem> foods;

  const FoodAnalysis({
    required this.foods,
  });
}

class FoodItem {
  final String foodName;
  final String servingSize;
  final int calories;
  final double protein;
  final double carbohydrates;
  final double fat;
  final double fiber;
  final double confidence;

  const FoodItem({
    required this.foodName,
    required this.servingSize,
    required this.calories,
    required this.protein,
    required this.carbohydrates,
    required this.fat,
    required this.fiber,
    required this.confidence,
  });
}