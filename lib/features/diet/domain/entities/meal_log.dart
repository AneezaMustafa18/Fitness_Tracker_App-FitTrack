class MealLog {
  final String id;
  final String name;
  final String mealType; // Breakfast, Lunch, Dinner, Snack
  final int calories;
  final double protein; // grams
  final double carbs; // grams
  final double fat; // grams
  final DateTime date;

  const MealLog({
    required this.id,
    required this.name,
    required this.mealType,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.date,
  });
}
