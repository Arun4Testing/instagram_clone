// ─────────────────────────────────────────────────────────────────────────────
// File    : lib/domain/entities/app_theme_mode.dart
// Layer   : Domain (entity)
// Purpose : The user's appearance choice. Plain Dart (no Flutter import);
//           the presentation layer maps it to Flutter's ThemeMode.
// Used by : ThemeRepository, ThemeCubit, App, ProfileTab settings sheet
// ─────────────────────────────────────────────────────────────────────────────

enum AppThemeMode { system, light, dark }
