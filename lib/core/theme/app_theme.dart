// ─────────────────────────────────────────────────────────────────────────────
// File    : lib/core/theme/app_theme.dart
// Layer   : Core
// Purpose : Builds the Material 3 light and dark ThemeData from an AppPalette.
//           The shared component themes (app bar, sheets, buttons, dividers,
//           snack bars...) are set here once so screens don't repeat them.
// Used by : App (lib/app.dart), DarkMediaScope
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'app_palette.dart';
import 'app_typography.dart';

class AppTheme {
  AppTheme._();

  static final ThemeData light = _build(Brightness.light, AppPalette.light);
  static final ThemeData dark = _build(Brightness.dark, AppPalette.dark);

  static TextStyle? _serif(TextStyle? style) =>
      style?.copyWith(fontFamily: AppTypography.serifFamily, fontFamilyFallback: AppTypography.serifFallback);

  static ThemeData _build(Brightness brightness, AppPalette p) {
    final base = ThemeData(brightness: brightness, useMaterial3: true);

    final scheme = ColorScheme.fromSeed(seedColor: p.accent, brightness: brightness).copyWith(
      primary: p.accent,
      onPrimary: p.onAccent,
      secondary: p.accent,
      secondaryContainer: p.surfaceAlt,
      onSecondaryContainer: p.text,
      surface: p.background,
      onSurface: p.text,
      onSurfaceVariant: p.muted,
      outline: p.border,
      outlineVariant: p.border,
    );

    final body = base.textTheme.apply(bodyColor: p.text, displayColor: p.text);
    final textTheme = body.copyWith(
      displayLarge: _serif(body.displayLarge),
      displayMedium: _serif(body.displayMedium),
      displaySmall: _serif(body.displaySmall),
      headlineLarge: _serif(body.headlineLarge),
      headlineMedium: _serif(body.headlineMedium),
      headlineSmall: _serif(body.headlineSmall),
      titleLarge: _serif(body.titleLarge),
    );

    return base.copyWith(
      colorScheme: scheme,
      scaffoldBackgroundColor: p.background,
      canvasColor: p.background,
      textTheme: textTheme,
      iconTheme: IconThemeData(color: p.text),
      extensions: <ThemeExtension<dynamic>>[p],
      dividerTheme: DividerThemeData(color: p.border, thickness: .5, space: 1),
      appBarTheme: AppBarTheme(
        backgroundColor: p.background,
        foregroundColor: p.text,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        titleTextStyle: AppTypography.serif(fontSize: 21, fontWeight: FontWeight.w600, color: p.text),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: p.surface,
        modalBackgroundColor: p.surface,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      ),
      iconButtonTheme: IconButtonThemeData(style: IconButton.styleFrom(foregroundColor: p.text)),
      listTileTheme: ListTileThemeData(iconColor: p.text, textColor: p.text),
      textButtonTheme: TextButtonThemeData(style: TextButton.styleFrom(foregroundColor: p.link)),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(backgroundColor: p.accent, foregroundColor: p.onAccent),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(color: p.accent),
      textSelectionTheme: TextSelectionThemeData(cursorColor: p.accent),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: p.text,
        contentTextStyle: TextStyle(color: p.background),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
