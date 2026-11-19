// ─────────────────────────────────────────────────────────────────────────────
// File    : lib/presentation/blocs/theme/theme_cubit.dart
// Layer   : Presentation (state)
// Purpose : Holds the current AppThemeMode (system / light / dark), emits it
//           immediately when changed and saves it so it survives restarts.
// Read by : App (rebuilds MaterialApp), ProfileTab settings sheet
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/app_theme_mode.dart';
import '../../../domain/repositories/theme_repository.dart';

class ThemeCubit extends Cubit<AppThemeMode> {
  ThemeCubit(ThemeRepository repository)
      : _repository = repository,
        super(repository.read());

  final ThemeRepository _repository;

  Future<void> setMode(AppThemeMode mode) async {
    emit(mode);
    await _repository.write(mode);
  }
}
