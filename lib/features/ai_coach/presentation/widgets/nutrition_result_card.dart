import 'package:flutter/material.dart';

import '../../../../app/themes/app_colors.dart';
import '../../domain/entities/food_analysis.dart';

class NutritionResultCard extends StatelessWidget {
  final FoodAnalysis analysis;

  const NutritionResultCard({
    super.key,
    required this.analysis,
  });

  @override
  Widget build(BuildContext context) {
    if (analysis.foods.isEmpty) {
      return _emptyResult();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Nutrition Analysis',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.normalText,
          ),
        ),
        const SizedBox(height: 12),
        ...analysis.foods.map(
              (food) => _foodCard(food),
        ),
      ],
    );
  }

  Widget _foodCard(FoodItem food) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.border,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 45,
                height: 45,
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withOpacity(0.10),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.restaurant_rounded,
                  color: AppColors.primaryBlue,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      food.foodName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.normalText,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      food.servingSize,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.secondaryText,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${food.calories} kcal',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryBlue,
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          Row(
            children: [
              Expanded(
                child: _nutritionItem(
                  icon: Icons.fitness_center_rounded,
                  label: 'Protein',
                  value: '${food.protein.toStringAsFixed(1)}g',
                ),
              ),
              Expanded(
                child: _nutritionItem(
                  icon: Icons.grain_rounded,
                  label: 'Carbs',
                  value: '${food.carbohydrates.toStringAsFixed(1)}g',
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          Row(
            children: [
              Expanded(
                child: _nutritionItem(
                  icon: Icons.water_drop_outlined,
                  label: 'Fat',
                  value: '${food.fat.toStringAsFixed(1)}g',
                ),
              ),
              Expanded(
                child: _nutritionItem(
                  icon: Icons.eco_outlined,
                  label: 'Fiber',
                  value: '${food.fiber.toStringAsFixed(1)}g',
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              const Icon(
                Icons.auto_awesome_rounded,
                size: 17,
                color: AppColors.primaryBlue,
              ),
              const SizedBox(width: 6),
              Text(
                'AI Confidence: ${(food.confidence * 100).toStringAsFixed(0)}%',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.secondaryText,
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          const Text(
            'Nutrition values are estimated based on the visible food and portion size.',
            style: TextStyle(
              fontSize: 11,
              color: AppColors.secondaryText,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _nutritionItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 19,
          color: AppColors.primaryBlue,
        ),
        const SizedBox(width: 7),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.secondaryText,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.normalText,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _emptyResult() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: const Text(
        'No food items were detected.',
        style: TextStyle(
          fontSize: 13,
          color: AppColors.secondaryText,
        ),
      ),
    );
  }
}