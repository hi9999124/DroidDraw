import 'package:flutter/material.dart';

/// Central design tokens for DroidDraw's dark, glass-panel UI.
abstract final class AppColors {
  static const background = Color(0xFF0E0E11);
  static const surface = Color(0xFF1A1A1F);
  static const border = Color(0x1FFFFFFF);
  static const accent = Color(0xFF8B7CFF);
  static const accentSoft = Color(0x338B7CFF);
  static const textPrimary = Color(0xFFF2F2F5);
  static const textSecondary = Color(0xFF9C9CA8);
  static const danger = Color(0xFFFF6B6B);
}

ThemeData buildAppTheme() {
  final base = ThemeData.dark(useMaterial3: true);
  return base.copyWith(
    scaffoldBackgroundColor: AppColors.background,
    colorScheme: base.colorScheme.copyWith(
      primary: AppColors.accent,
      surface: AppColors.surface,
      error: AppColors.danger,
    ),
    textTheme: base.textTheme.apply(
      bodyColor: AppColors.textPrimary,
      displayColor: AppColors.textPrimary,
    ),
    sliderTheme: base.sliderTheme.copyWith(
      activeTrackColor: AppColors.accent,
      inactiveTrackColor: AppColors.border,
      thumbColor: AppColors.accent,
      overlayColor: AppColors.accentSoft,
      trackHeight: 2,
    ),
    dividerColor: AppColors.border,
    iconTheme: const IconThemeData(color: AppColors.textPrimary),
    popupMenuTheme: PopupMenuThemeData(
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.border),
      ),
    ),
  );
}
