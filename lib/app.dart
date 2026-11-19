// ─────────────────────────────────────────────────────────────────────────────
// File    : lib/app.dart
// Layer   : App (root widget)
// Purpose : The MaterialApp: title, dark theme and the first screen (AuthGate).
//           Repositories and Blocs are provided ABOVE this widget in main.dart,
//           so every route pushed by the Navigator can read them.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'core/constants/app_constants.dart';
import 'core/theme/app_theme.dart';
import 'presentation/pages/auth/auth_gate.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: AppConstants.appName,
        theme: AppTheme.dark,
        home: const AuthGate(),
      );
}
