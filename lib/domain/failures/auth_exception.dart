// ─────────────────────────────────────────────────────────────────────────────
// File    : lib/domain/failures/auth_exception.dart
// Layer   : Domain (failure)
// Purpose : Business-rule error raised by AuthRepository (wrong password,
//           username taken, ...). The message is safe to show to the user.
// ─────────────────────────────────────────────────────────────────────────────

class AuthException implements Exception {
  const AuthException(this.message);

  final String message;

  @override
  String toString() => 'AuthException: $message';
}
