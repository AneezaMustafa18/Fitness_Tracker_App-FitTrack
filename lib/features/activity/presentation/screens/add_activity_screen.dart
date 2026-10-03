import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../app/themes/app_colors.dart';
import '../../domain/entities/activity.dart';
import '../providers/activity_provider.dart';

class AddActivityScreen extends StatefulWidget {
  const AddActivityScreen({super.key});

  @override
  State<AddActivityScreen> createState() => _AddActivityScreenState();
}

class _AddActivityScreenState extends State<AddActivityScreen> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _durationController = TextEditingController();
  final _caloriesController = TextEditingController();
  final _stepsController = TextEditingController();
  final _distanceController = TextEditingController();

  String _selectedType = 'Workout';
  DateTime _selectedDate = DateTime.now();

  final List<String> _activityTypes = [
    'Workout',
    'Walking',
    'Running',
    'Cycling',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _durationController.dispose();
    _caloriesController.dispose();
    _stepsController.dispose();
    _distanceController.dispose();
    super.dispose();
  }

  // ============================================================
  // DATE PICKER
  // ============================================================

  Future<void> _selectDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null && mounted) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  // ============================================================
  // CLEAR FORM
  // ============================================================

  void _clearForm() {
    _titleController.clear();
    _durationController.clear();
    _caloriesController.clear();
    _stepsController.clear();
    _distanceController.clear();

    _formKey.currentState?.reset();

    if (!mounted) return;

    setState(() {
      _selectedType = 'Workout';
      _selectedDate = DateTime.now();
    });
  }

  // ============================================================
  // SAVE ACTIVITY
  // ============================================================

  Future<void> _saveActivity() async {
    // Hide keyboard
    FocusScope.of(context).unfocus();

    // Validate form
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final provider = context.read<ActivityProvider>();

    // Create activity object
    final activity = Activity(
      id: '',
      title: _titleController.text.trim(),
      type: _selectedType,
      durationMinutes:
      int.tryParse(_durationController.text.trim()) ?? 0,
      calories:
      int.tryParse(_caloriesController.text.trim()) ?? 0,
      steps:
      int.tryParse(_stepsController.text.trim()) ?? 0,
      distance:
      double.tryParse(_distanceController.text.trim()) ?? 0.0,
      date: _selectedDate,
    );

    try {
      // ========================================================
      // WAIT FOR FIREBASE SAVE
      // ========================================================

      await provider.createActivity(activity);

      if (!mounted) return;

      // ========================================================
      // CLEAR FIELDS AFTER SUCCESSFUL FIREBASE SAVE
      // ========================================================

      _titleController.clear();
      _durationController.clear();
      _caloriesController.clear();
      _stepsController.clear();
      _distanceController.clear();

      _formKey.currentState?.reset();

      setState(() {
        _selectedType = 'Workout';
        _selectedDate = DateTime.now();
      });

      // ========================================================
      // SUCCESS SNACKBAR
      // ========================================================

      ScaffoldMessenger.of(context).hideCurrentSnackBar();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Activity saved successfully!',
          ),
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 2),
        ),
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).hideCurrentSnackBar();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            provider.errorMessage ??
                'Unable to save activity. Please try again.',
          ),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  // ============================================================
  // REQUIRED VALIDATOR
  // ============================================================

  String? _requiredValidator(
      String? value,
      String fieldName,
      ) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }

    return null;
  }

  // ============================================================
  // NUMBER VALIDATOR
  // ============================================================

  String? _numberValidator(
      String? value,
      String fieldName,
      ) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }

    if (num.tryParse(value.trim()) == null) {
      return 'Enter a valid number';
    }

    return null;
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,

      // ========================================================
      // APP BAR
      // ========================================================

      appBar: AppBar(
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.normalText,
        elevation: 0,
        title: const Text(
          'Add Activity',
          style: TextStyle(
            color: AppColors.normalText,
            fontSize: 21,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
      ),

      // ========================================================
      // BODY
      // ========================================================

      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              24,
              10,
              24,
              30,
            ),
            physics: const BouncingScrollPhysics(),
            children: [
              // ==================================================
              // ACTIVITY TYPE
              // ==================================================

              _buildActivityType(),

              const SizedBox(height: 22),

              // ==================================================
              // ACTIVITY NAME
              // ==================================================

              _buildLabel('Activity Name'),

              const SizedBox(height: 8),

              TextFormField(
                controller: _titleController,
                textInputAction: TextInputAction.next,
                validator: (value) {
                  return _requiredValidator(
                    value,
                    'Activity name',
                  );
                },
                decoration: _inputDecoration(
                  hintText: 'e.g. Morning Workout',
                  prefixIcon: Icons.fitness_center_rounded,
                ),
              ),

              const SizedBox(height: 18),

              // ==================================================
              // DURATION
              // ==================================================

              _buildLabel('Duration'),

              const SizedBox(height: 8),

              TextFormField(
                controller: _durationController,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
                validator: (value) {
                  return _numberValidator(
                    value,
                    'Duration',
                  );
                },
                decoration: _inputDecoration(
                  hintText: 'Minutes',
                  prefixIcon: Icons.timer_outlined,
                ),
              ),

              const SizedBox(height: 18),

              // ==================================================
              // CALORIES
              // ==================================================

              _buildLabel('Calories'),

              const SizedBox(height: 8),

              TextFormField(
                controller: _caloriesController,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
                validator: (value) {
                  return _numberValidator(
                    value,
                    'Calories',
                  );
                },
                decoration: _inputDecoration(
                  hintText: 'kcal',
                  prefixIcon:
                  Icons.local_fire_department_outlined,
                ),
              ),

              const SizedBox(height: 18),

              // ==================================================
              // STEPS
              // ==================================================

              _buildLabel('Steps'),

              const SizedBox(height: 8),

              TextFormField(
                controller: _stepsController,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
                validator: (value) {
                  return _numberValidator(
                    value,
                    'Steps',
                  );
                },
                decoration: _inputDecoration(
                  hintText: 'Number of steps',
                  prefixIcon:
                  Icons.directions_walk_outlined,
                ),
              ),

              const SizedBox(height: 18),

              // ==================================================
              // DISTANCE
              // ==================================================

              _buildLabel('Distance'),

              const SizedBox(height: 8),

              TextFormField(
                controller: _distanceController,
                keyboardType:
                const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                textInputAction: TextInputAction.done,
                validator: (value) {
                  return _numberValidator(
                    value,
                    'Distance',
                  );
                },
                decoration: _inputDecoration(
                  hintText: 'Distance in km',
                  prefixIcon: Icons.route_outlined,
                ),
              ),

              const SizedBox(height: 18),

              // ==================================================
              // DATE
              // ==================================================

              _buildLabel('Date'),

              const SizedBox(height: 8),

              InkWell(
                onTap: _selectDate,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  height: 54,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.border,
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.calendar_today_outlined,
                        color: AppColors.primaryBlue,
                        size: 20,
                      ),

                      const SizedBox(width: 12),

                      Text(
                        _formatDate(_selectedDate),
                        style: const TextStyle(
                          color: AppColors.normalText,
                          fontSize: 14,
                        ),
                      ),

                      const Spacer(),

                      const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: AppColors.secondaryText,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // ==================================================
              // SAVE BUTTON
              // ==================================================

              Consumer<ActivityProvider>(
                builder: (
                    context,
                    provider,
                    child,
                    ) {
                  return SizedBox(
                    height: 54,
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: provider.isLoading
                          ? null
                          : _saveActivity,
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                        AppColors.primaryBlue,
                        foregroundColor:
                        AppColors.white,
                        disabledBackgroundColor:
                        AppColors.primaryBlue
                            .withValues(alpha: 0.5),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                          BorderRadius.circular(12),
                        ),
                      ),
                      child: provider.isLoading
                          ? const SizedBox(
                        width: 23,
                        height: 23,
                        child:
                        CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color:
                          AppColors.white,
                        ),
                      )
                          : const Text(
                        'Save Activity',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight:
                          FontWeight.w600,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // ACTIVITY TYPE
  // ============================================================

  Widget _buildActivityType() {
    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [
        _buildLabel('Activity Type'),

        const SizedBox(height: 10),

        SizedBox(
          height: 44,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _activityTypes.length,
            separatorBuilder: (_, __) =>
            const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final type = _activityTypes[index];

              final isSelected =
                  _selectedType == type;

              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedType = type;
                  });
                },
                child: AnimatedContainer(
                  duration:
                  const Duration(milliseconds: 200),
                  padding:
                  const EdgeInsets.symmetric(
                    horizontal: 17,
                  ),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primaryBlue
                        : AppColors.white,
                    borderRadius:
                    BorderRadius.circular(22),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primaryBlue
                          : AppColors.border,
                    ),
                  ),
                  child: Text(
                    type,
                    style: TextStyle(
                      color: isSelected
                          ? AppColors.white
                          : AppColors.secondaryText,
                      fontSize: 13,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.w500,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // ============================================================
  // LABEL
  // ============================================================

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: AppColors.normalText,
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  // ============================================================
  // INPUT DECORATION
  // ============================================================

  InputDecoration _inputDecoration({
    required String hintText,
    required IconData prefixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(
        color: AppColors.secondaryText,
        fontSize: 13,
      ),
      prefixIcon: Icon(
        prefixIcon,
        color: AppColors.primaryBlue,
        size: 20,
      ),
      filled: true,
      fillColor: AppColors.white,
      contentPadding:
      const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 15,
      ),
      border: OutlineInputBorder(
        borderRadius:
        BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: AppColors.border,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius:
        BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: AppColors.border,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius:
        BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: AppColors.primaryBlue,
          width: 1.5,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius:
        BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: AppColors.error,
        ),
      ),
      focusedErrorBorder:
      OutlineInputBorder(
        borderRadius:
        BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: AppColors.error,
          width: 1.5,
        ),
      ),
    );
  }

  // ============================================================
  // FORMAT DATE
  // ============================================================

  String _formatDate(DateTime date) {
    final day =
    date.day.toString().padLeft(2, '0');

    final month =
    date.month.toString().padLeft(2, '0');

    final year = date.year.toString();

    return '$day/$month/$year';
  }
}
