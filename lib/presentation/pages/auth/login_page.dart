// ─────────────────────────────────────────────────────────────────────────────
// File    : lib/presentation/pages/auth/login_page.dart
// Layer   : Presentation (page)
// Purpose : Login / sign-up screen. One form toggles between "Log in" and
//           "Sign up" (adds a full-name field). Errors from AuthBloc are shown
//           in a SnackBar through a BlocListener.
// Dispatches : LoginRequested, SignUpRequested (AuthBloc)
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../widgets/ig_logo.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _username = TextEditingController();
  final _password = TextEditingController();
  final _name = TextEditingController();
  bool _isSignUp = false;
  bool _hidePassword = true;

  @override
  void dispose() {
    _username.dispose();
    _password.dispose();
    _name.dispose();
    super.dispose();
  }

  InputDecoration _decoration(String hint, {Widget? suffixIcon}) =>
      InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 16),
        suffixIcon: suffixIcon,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: Colors.grey.shade700),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: Colors.white54),
        ),
      );

  void _submit() {
    final bloc = context.read<AuthBloc>();
    if (_isSignUp) {
      bloc.add(SignUpRequested(
          username: _username.text,
          password: _password.text,
          name: _name.text));
    } else {
      bloc.add(
          LoginRequested(username: _username.text, password: _password.text));
    }
  }

  @override
  Widget build(BuildContext context) => BlocListener<AuthBloc, AuthState>(
        listenWhen: (previous, current) =>
            current.error != null && previous.stamp != current.stamp,
        listener: (context, state) => ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(state.error!))),
        child: Scaffold(
          backgroundColor: AppColors.authBackground,
          body: SafeArea(
            child: LayoutBuilder(
              builder: (context, box) => SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: box.maxHeight),
                  child: IntrinsicHeight(
                    child: Column(children: [
                      const SizedBox(height: 24),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('English (India)',
                                style: TextStyle(
                                    color: Colors.grey.shade400, fontSize: 15)),
                            Icon(Icons.keyboard_arrow_down,
                                color: Colors.grey.shade400),
                          ]),
                      const Spacer(),
                      const IgLogo(62),
                      const Spacer(flex: 2),
                      if (_isSignUp) ...[
                        TextField(
                            controller: _name,
                            decoration: _decoration('Full name')),
                        const SizedBox(height: 12),
                      ],
                      TextField(
                        controller: _username,
                        decoration: _decoration(
                            'Username, email address or mobile number'),
                        autocorrect: false,
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _password,
                        obscureText: _hidePassword,
                        decoration: _decoration(
                          'Password',
                          suffixIcon: Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: IconButton(
                              icon: Icon(
                                _hidePassword
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                color: Colors.grey.shade400,
                              ),
                              onPressed: () => setState(
                                  () => _hidePassword = !_hidePassword),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: FilledButton(
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            shape: const StadiumBorder(),
                          ),
                          onPressed: _submit,
                          child: Text(
                            _isSignUp ? 'Sign up' : 'Log in',
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      const Text(
                        'Forgotten password?',
                        style: TextStyle(
                            fontSize: 17, fontWeight: FontWeight.w500),
                      ),
                      const Spacer(flex: 3),
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            shape: const StadiumBorder(),
                            side: const BorderSide(color: AppColors.link),
                          ),
                          onPressed: () =>
                              setState(() => _isSignUp = !_isSignUp),
                          child: Text(
                            _isSignUp
                                ? 'I already have an account'
                                : 'Create new account',
                            style: const TextStyle(
                                color: AppColors.link, fontSize: 18),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text('∞ Meta',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.w500)),
                      const SizedBox(height: 12),
                    ]),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
}
