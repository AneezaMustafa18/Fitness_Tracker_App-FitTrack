import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../app/themes/app_colors.dart';
import '../providers/diet_provider.dart';

class AddMealScreen extends StatefulWidget {
  const AddMealScreen({super.key});

  @override
  State<AddMealScreen> createState() => _AddMealScreenState();
}

class _AddMealScreenState extends State<AddMealScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _caloriesController = TextEditingController();
  final _proteinController = TextEditingController();
  final _carbsController = TextEditingController();
  final _fatController = TextEditingController();

  String _mealType = 'Breakfast';
  bool _isSaving = false;

  static const _mealTypes = ['Breakfast', 'Lunch', 'Dinner', 'Snack'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<DietProvider>().startListening();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _caloriesController.dispose();
    _proteinController.dispose();
    _carbsController.dispose();
    _fatController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      await context.read<DietProvider>().addMeal(
        name: _nameController.text.trim(),
        mealType: _mealType,
        calories: int.parse(_caloriesController.text.trim()),
        protein: double.tryParse(_proteinController.text.trim()) ?? 0,
        carbs: double.tryParse(_carbsController.text.trim()) ?? 0,
        fat: double.tryParse(_fatController.text.trim()) ?? 0,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Meal logged successfully')),
        );
        _nameController.clear();
        _caloriesController.clear();
        _proteinController.clear();
        _carbsController.clear();
        _fatController.clear();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save meal: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _editGoal() async {
    final provider = context.read<DietProvider>();
    final controller = TextEditingController(text: provider.calorieGoal.toString());

    final result = await showDialog<int>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Set daily calorie goal'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Goal (kcal)', hintText: 'e.g. 2000'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, int.tryParse(controller.text)),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (result != null && result > 0) {
      await provider.setCalorieGoal(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        title: const Text('Diet & Nutrition', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700)),
        actions: [
          IconButton(
            onPressed: _editGoal,
            icon: const Icon(Icons.flag_outlined, color: AppColors.primaryBlue),
            tooltip: 'Set daily calorie goal',
          ),
        ],
      ),
      body: Consumer<DietProvider>(
        builder: (context, provider, _) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _CalorieSummaryCard(provider: provider),
                const SizedBox(height: 24),
                const Text('Log a meal', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                const SizedBox(height: 14),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(labelText: 'Meal name', hintText: 'e.g. Grilled chicken & rice'),
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter meal name' : null,
                      ),
                      const SizedBox(height: 14),
                      DropdownButtonFormField<String>(
                        initialValue: _mealType,
                        decoration: const InputDecoration(labelText: 'Meal type'),
                        items: _mealTypes
                            .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                            .toList(),
                        onChanged: (v) => setState(() => _mealType = v ?? _mealType),
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _caloriesController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Calories (kcal)'),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return 'Enter calories';
                          if (int.tryParse(v.trim()) == null) return 'Enter a valid number';
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _proteinController,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              decoration: const InputDecoration(labelText: 'Protein (g)'),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextFormField(
                              controller: _carbsController,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              decoration: const InputDecoration(labelText: 'Carbs (g)'),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextFormField(
                              controller: _fatController,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              decoration: const InputDecoration(labelText: 'Fat (g)'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isSaving ? null : _save,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryBlue,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: _isSaving
                              ? const SizedBox(
                              height: 20, width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                              : const Text('Save Meal', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),
                if (provider.todayMeals.isNotEmpty) ...[
                  const Text("Today's meals", style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                  const SizedBox(height: 8),
                  ...provider.todayMeals.reversed.map(
                        (meal) => Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: const Icon(Icons.restaurant, color: AppColors.primaryBlue),
                        title: Text(meal.name),
                        subtitle: Text('${meal.mealType} • ${meal.calories} kcal • P${meal.protein.toStringAsFixed(0)} C${meal.carbs.toStringAsFixed(0)} F${meal.fat.toStringAsFixed(0)}'),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline, color: AppColors.error),
                          onPressed: () => provider.removeMeal(meal.id),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

class _CalorieSummaryCard extends StatelessWidget {
  final DietProvider provider;

  const _CalorieSummaryCard({required this.provider});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.primaryBlue.withOpacity(0.06),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${provider.totalCalories} / ${provider.calorieGoal} kcal',
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
              Text('${(provider.progress * 100).round()}%',
                  style: const TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: provider.progress,
              minHeight: 8,
              backgroundColor: AppColors.border,
              valueColor: const AlwaysStoppedAnimation(AppColors.primaryBlue),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _MacroTag(label: 'Protein', value: provider.totalProtein),
              _MacroTag(label: 'Carbs', value: provider.totalCarbs),
              _MacroTag(label: 'Fat', value: provider.totalFat),
            ],
          ),
        ],
      ),
    );
  }
}

class _MacroTag extends StatelessWidget {
  final String label;
  final double value;

  const _MacroTag({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('${value.toStringAsFixed(0)}g', style: const TextStyle(fontWeight: FontWeight.w700)),
        Text(label, style: const TextStyle(color: AppColors.secondaryText, fontSize: 12)),
      ],
    );
  }
}
