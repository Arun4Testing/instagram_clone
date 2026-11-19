// ─────────────────────────────────────────────────────────────────────────────
// File    : lib/data/repositories/theme_repository_impl.dart
// Layer   : Data (repository implementation)
// Purpose : Persists the appearance choice through LocalStorage.
//           Defaults to "follow the system" on first launch.
// Implements : ThemeRepository
// ─────────────────────────────────────────────────────────────────────────────

import '../../domain/entities/app_theme_mode.dart';
import '../../domain/repositories/theme_repository.dart';
import '../datasources/local_storage.dart';

class ThemeRepositoryImpl implements ThemeRepository {
  ThemeRepositoryImpl(this._storage);

  final LocalStorage _storage;

  @override
  AppThemeMode read() {
    final raw = _storage.readThemeMode();
    return AppThemeMode.values.firstWhere(
      (mode) => mode.name == raw,
      orElse: () => AppThemeMode.system,
    );
  }

  @override
  Future<void> write(AppThemeMode mode) => _storage.writeThemeMode(mode.name);
}
