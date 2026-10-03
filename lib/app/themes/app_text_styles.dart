import 'package:fitness_tracker_app/app/themes/app_colors.dart' show AppColors;
import 'package:flutter/material.dart';



class AppTextStyles {
  AppTextStyles._();

  static final TextStyle headingLarge = TextStyle(
    color: AppColors.textPrimary,
    fontSize: 28,
    fontWeight: FontWeight.w700,
  );

  static const TextStyle headingMedium = TextStyle(
    color: AppColors.textPrimary,
    fontSize: 22,
    fontWeight: FontWeight.w700,
  );

  static const TextStyle title = TextStyle(
    color: AppColors.textPrimary,
    fontSize: 18,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle body = TextStyle(
    color: AppColors.textPrimary,
    fontSize: 14,
    fontWeight: FontWeight.w400,
  );

  static const TextStyle bodyMedium = TextStyle(
    color: AppColors.secondaryText,
    fontSize: 13,
    fontWeight: FontWeight.w400,
  );

  static const TextStyle button = TextStyle(
    color: AppColors.white,
    fontSize: 14,
    fontWeight: FontWeight.w600,
  );
}