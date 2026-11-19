// ─────────────────────────────────────────────────────────────────────────────
// File    : lib/core/theme/app_theme.dart
// Layer   : Core
// Purpose : Builds the Material 3 dark ThemeData used by MaterialApp.
// Used by : App (lib/app.dart)
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get dark => ThemeData.dark(useMaterial3: true).copyWith(
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: const ColorScheme.dark(primary: AppColors.primary),
      );
}
