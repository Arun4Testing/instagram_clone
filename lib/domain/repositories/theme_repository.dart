// ─────────────────────────────────────────────────────────────────────────────
// File    : lib/domain/repositories/theme_repository.dart
// Layer   : Domain (repository contract)
// Purpose : Reads and saves the user's appearance choice.
// Implemented by : ThemeRepositoryImpl (data layer)
// ─────────────────────────────────────────────────────────────────────────────

import '../entities/app_theme_mode.dart';

abstract class ThemeRepository {
  AppThemeMode read();

  Future<void> write(AppThemeMode mode);
}
