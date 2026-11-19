// ─────────────────────────────────────────────────────────────────────────────
// File    : lib/app.dart
// Layer   : App (root widget)
// Purpose : The MaterialApp: title, light + dark themes, the theme mode chosen
//           by the user (ThemeCubit) and the first screen (AuthGate).
//           Repositories and Blocs are provided ABOVE this widget in main.dart,
//           so every route pushed by the Navigator can read them.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/constants/app_constants.dart';
import 'core/theme/app_theme.dart';
import 'domain/entities/app_theme_mode.dart';
import 'presentation/blocs/theme/theme_cubit.dart';
import 'presentation/pages/auth/auth_gate.dart';

class App extends StatelessWidget {
  const App({super.key});

  static ThemeMode _toThemeMode(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.light:
        return ThemeMode.light;
      case AppThemeMode.dark:
        return ThemeMode.dark;
      case AppThemeMode.system:
        return ThemeMode.system;
    }
  }

  @override
  Widget build(BuildContext context) => BlocBuilder<ThemeCubit, AppThemeMode>(
        builder: (context, mode) => MaterialApp(
          debugShowCheckedModeBanner: false,
          title: AppConstants.appName,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: _toThemeMode(mode),
          // Keeps the status-bar icons readable on the active background.
          builder: (context, child) {
            final isDark = Theme.of(context).brightness == Brightness.dark;
            return AnnotatedRegion<SystemUiOverlayStyle>(
              value: (isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark)
                  .copyWith(statusBarColor: Colors.transparent),
              child: child ?? const SizedBox.shrink(),
            );
          },
          home: const AuthGate(),
        ),
      );
}
