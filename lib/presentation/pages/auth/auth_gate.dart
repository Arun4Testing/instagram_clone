// ─────────────────────────────────────────────────────────────────────────────
// File    : lib/presentation/pages/auth/auth_gate.dart
// Layer   : Presentation (page)
// Purpose : Decides the first screen: splash for a short time, then the login
//           page or the main app shell depending on AuthBloc's state.
// Used by : App (lib/app.dart)
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_constants.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../shell/app_shell.dart';
import '../splash/splash_page.dart';
import 'login_page.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  bool _splashDone = false;

  @override
  void initState() {
    super.initState();
    Future<void>.delayed(AppConstants.splashDuration, () {
      if (mounted) setState(() => _splashDone = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_splashDone) return const SplashPage();
    return BlocBuilder<AuthBloc, AuthState>(
      buildWhen: (previous, current) => previous.loggedIn != current.loggedIn,
      builder: (_, state) =>
          state.loggedIn ? const AppShell() : const LoginPage(),
    );
  }
}
