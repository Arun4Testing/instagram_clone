// ─────────────────────────────────────────────────────────────────────────────
// File    : lib/domain/repositories/auth_repository.dart
// Layer   : Domain (contract)
// Purpose : What the app needs from an authentication source. The Bloc depends
//           on THIS interface, never on SharedPreferences or a server.
// Impl    : data/repositories/auth_repository_impl.dart
// ─────────────────────────────────────────────────────────────────────────────

import '../entities/app_user.dart';

abstract class AuthRepository {
  /// Returns the previously signed-in user, or null.
  Future<AppUser?> restoreSession();

  /// Throws [AuthException] when credentials are wrong.
  Future<AppUser> login({required String username, required String password});

  /// Throws [AuthException] when input is invalid or the username is taken.
  Future<AppUser> signUp({
    required String username,
    required String password,
    required String name,
  });

  Future<void> logout();

  Future<AppUser> updateProfile({required String name, required String bio});
}
