// ─────────────────────────────────────────────────────────────────────────────
// File    : lib/data/repositories/auth_repository_impl.dart
// Layer   : Data (repository implementation)
// Purpose : Local, offline authentication backed by [LocalStorage].
//           Validates input, keeps the user list and active session, and maps
//           [UserModel] -> [AppUser] so passwords never reach the UI.
// Note    : Passwords are stored in plain text because this is an offline demo.
//           Replace with a hashed/remote implementation for production.
// ─────────────────────────────────────────────────────────────────────────────

import '../../core/constants/app_constants.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/failures/auth_exception.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/local_storage.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._storage) {
    _users = _storage.readUsers();
    _currentUsername = _storage.readSession();
  }

  final LocalStorage _storage;
  late List<UserModel> _users;
  String? _currentUsername;

  int get _currentIndex => _users.indexWhere((u) => u.username == _currentUsername);

  @override
  Future<AppUser?> restoreSession() async {
    final i = _currentIndex;
    return i < 0 ? null : _users[i].toEntity();
  }

  @override
  Future<AppUser> login({required String username, required String password}) async {
    final key = username.trim().toLowerCase();
    final i = _users.indexWhere((u) => u.username == key && u.password == password);
    if (i < 0) throw const AuthException('Incorrect username or password');
    _currentUsername = key;
    await _storage.writeSession(key);
    return _users[i].toEntity();
  }

  @override
  Future<AppUser> signUp({
    required String username,
    required String password,
    required String name,
  }) async {
    final key = username.trim().toLowerCase();
    if (key.isEmpty || password.length < AppConstants.minPasswordLength) {
      throw const AuthException(
          'Enter a username and a password (${AppConstants.minPasswordLength}+ characters)');
    }
    if (_users.any((u) => u.username == key)) {
      throw const AuthException('Username already taken');
    }
    final user = UserModel(username: key, password: password, name: name.trim());
    _users = [..._users, user];
    _currentUsername = key;
    await _storage.writeUsers(_users);
    await _storage.writeSession(key);
    return user.toEntity();
  }

  @override
  Future<void> logout() async {
    _currentUsername = null;
    await _storage.writeSession(null);
  }

  @override
  Future<AppUser> updateProfile({required String name, required String bio}) async {
    final i = _currentIndex;
    if (i < 0) throw const AuthException('You are not signed in');
    final updated = _users[i].copyWith(name: name, bio: bio);
    _users = [..._users]..[i] = updated;
    await _storage.writeUsers(_users);
    return updated.toEntity();
  }
}
