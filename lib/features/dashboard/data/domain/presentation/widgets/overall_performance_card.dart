import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../../app/themes/app_colors.dart';
import '../../../../../activity/domain/entities/activity.dart';
import '../../../../../diet/presentation/providers/diet_provider.dart';
import '../../../../../water/presentation/providers/water_provider.dart';

/// Default daily exercise-minutes goal, editable through the flag icon.
const int kDefaultExerciseGoalMinutes = 30;

/// Card shown on the dashboard summarising today's progress across
/// Exercise, Water and Diet, plus a combined "Daily Score".
class OverallPerformanceCard extends StatelessWidget {
  final List<Activity> todayActivities;

  const OverallPerformanceCard({super.key, required this.todayActivities});

  int get _exerciseMinutesToday =>
      todayActivities.fold(0, (sum, a) => sum + a.durationMinutes);

  Stream<int?> _exerciseGoalStream() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return Stream.value(null);
    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('goals')
        .doc('exercise')
        .snapshots()
        .map((doc) => (doc.data()?['goalMinutes'] as num?)?.toInt());
  }

  Future<void> _setExerciseGoal(BuildContext context, int minutes) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('goals')
        .doc('exercise')
        .set({'goalMinutes': minutes}, SetOptions(merge: true));
  }

  Future<void> _editExerciseGoal(BuildContext context, int currentGoal) async {
    final controller = TextEditingController(text: currentGoal.toString());

    final result = await showDialog<int>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Set daily exercise goal'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Goal (minutes)', hintText: 'e.g. 30'),
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
      await _setExerciseGoal(context, result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<int?>(
      stream: _exerciseGoalStream(),
      builder: (context, goalSnapshot) {
        final exerciseGoal = goalSnapshot.data ?? kDefaultExerciseGoalMinutes;
        final exerciseProgress =
        exerciseGoal == 0 ? 0.0 : (_exerciseMinutesToday / exerciseGoal).clamp(0.0, 1.0);

        return Consumer2<WaterProvider, DietProvider>(
          builder: (context, water, diet, _) {
            final overallScore =
            ((exerciseProgress + water.progress + diet.progress) / 3 * 100).round();

            return Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Overall Performance',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primaryBlue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '$overallScore% today',
                          style: const TextStyle(
                            color: AppColors.primaryBlue,
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _CategoryProgress(
                          icon: Icons.fitness_center_rounded,
                          color: Colors.orange,
                          label: 'Exercise',
                          value: '$_exerciseMinutesToday/$exerciseGoal min',
                          progress: exerciseProgress,
                          onEditGoal: () => _editExerciseGoal(context, exerciseGoal),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _CategoryProgress(
                          icon: Icons.water_drop_rounded,
                          color: Colors.lightBlue,
                          label: 'Water',
                          value: '${water.totalMl}/${water.goalMl} ml',
                          progress: water.progress,
                          onEditGoal: null,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _CategoryProgress(
                          icon: Icons.restaurant_rounded,
                          color: Colors.green,
                          label: 'Diet',
                          value: '${diet.totalCalories}/${diet.calorieGoal} kcal',
                          progress: diet.progress,
                          onEditGoal: null,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _CategoryProgress extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final String value;
  final double progress;
  final VoidCallback? onEditGoal;

  const _CategoryProgress({
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
    required this.progress,
    required this.onEditGoal,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onEditGoal,
      child: Column(
        children: [
          SizedBox(
            width: 56,
            height: 56,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 56,
                  height: 56,
                  child: CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 5,
                    backgroundColor: AppColors.border,
                    valueColor: AlwaysStoppedAnimation(color),
                  ),
                ),
                Icon(icon, color: color, size: 22),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 10.5, color: AppColors.secondaryText),
          ),
        ],
      ),
    );
  }
}
