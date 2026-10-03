import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../app/themes/app_colors.dart';
import '../providers/water_provider.dart';

class AddWaterScreen extends StatefulWidget {
  const AddWaterScreen({super.key});

  @override
  State<AddWaterScreen> createState() => _AddWaterScreenState();
}

class _AddWaterScreenState extends State<AddWaterScreen> {
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<WaterProvider>().startListening();
    });
  }

  Future<void> _addAmount(int ml) async {
    setState(() => _isSaving = true);
    try {
      await context.read<WaterProvider>().addWater(ml);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Added ${ml}ml of water')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add water: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _editGoal() async {
    final provider = context.read<WaterProvider>();
    final controller = TextEditingController(text: provider.goalMl.toString());

    final result = await showDialog<int>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Set daily water goal'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Goal (ml)',
            hintText: 'e.g. 2000',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final value = int.tryParse(controller.text);
              Navigator.pop(dialogContext, value);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (result != null && result > 0) {
      await provider.setGoalMl(result);
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
        title: const Text(
          'Water Intake',
          style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
            onPressed: _editGoal,
            icon: const Icon(Icons.flag_outlined, color: AppColors.primaryBlue),
            tooltip: 'Set daily goal',
          ),
        ],
      ),
      body: Consumer<WaterProvider>(
        builder: (context, provider, _) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _WaterProgressRing(
                  progress: provider.progress,
                  totalMl: provider.totalMl,
                  goalMl: provider.goalMl,
                ),
                const SizedBox(height: 8),
                Text(
                  '${provider.glassesConsumed} / ${provider.glassGoal} glasses (250ml each)',
                  style: const TextStyle(color: AppColors.secondaryText, fontSize: 13),
                ),
                const SizedBox(height: 28),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Quick add',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _QuickAddChip(label: '+250ml', onTap: () => _addAmount(250), enabled: !_isSaving),
                    _QuickAddChip(label: '+500ml', onTap: () => _addAmount(500), enabled: !_isSaving),
                    _QuickAddChip(label: '+750ml', onTap: () => _addAmount(750), enabled: !_isSaving),
                    _QuickAddChip(label: '+1L', onTap: () => _addAmount(1000), enabled: !_isSaving),
                  ],
                ),
                const SizedBox(height: 28),
                if (provider.todayLogs.isNotEmpty) ...[
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Today's logs",
                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...provider.todayLogs.reversed.map(
                        (log) => Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: const Icon(Icons.water_drop, color: AppColors.primaryBlue),
                        title: Text('${log.amountMl} ml'),
                        subtitle: Text(
                          '${log.date.hour.toString().padLeft(2, '0')}:${log.date.minute.toString().padLeft(2, '0')}',
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline, color: AppColors.error),
                          onPressed: () => provider.removeLog(log.id),
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

class _WaterProgressRing extends StatelessWidget {
  final double progress;
  final int totalMl;
  final int goalMl;

  const _WaterProgressRing({
    required this.progress,
    required this.totalMl,
    required this.goalMl,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 180,
      height: 180,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 180,
            height: 180,
            child: CircularProgressIndicator(
              value: progress,
              strokeWidth: 12,
              backgroundColor: AppColors.border,
              valueColor: const AlwaysStoppedAnimation(AppColors.primaryBlue),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$totalMl ml',
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
              ),
              Text(
                'of $goalMl ml',
                style: const TextStyle(color: AppColors.secondaryText, fontSize: 13),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuickAddChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final bool enabled;

  const _QuickAddChip({required this.label, required this.onTap, required this.enabled});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.primaryBlue.withOpacity(0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.primaryBlue.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.water_drop, color: AppColors.primaryBlue, size: 18),
            const SizedBox(width: 8),
            Text(label, style: const TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}
