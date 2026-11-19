// ─────────────────────────────────────────────────────────────────────────────
// File    : lib/presentation/blocs/auth/auth_event.dart
// Layer   : Presentation (bloc events)
// Purpose : Everything the UI can ask the AuthBloc to do.
// ─────────────────────────────────────────────────────────────────────────────

part of 'auth_bloc.dart';

abstract class AuthEvent {
  const AuthEvent();
}

/// Restore a saved session when the app starts.
class AuthStarted extends AuthEvent {
  const AuthStarted();
}

class LoginRequested extends AuthEvent {
  const LoginRequested({required this.username, required this.password});
  final String username;
  final String password;
}

class SignUpRequested extends AuthEvent {
  const SignUpRequested({required this.username, required this.password, required this.name});
  final String username;
  final String password;
  final String name;
}

class LoggedOut extends AuthEvent {
  const LoggedOut();
}

class ProfileUpdated extends AuthEvent {
  const ProfileUpdated({required this.name, required this.bio});
  final String name;
  final String bio;
}
