// ─────────────────────────────────────────────────────────────────────────────
// File    : lib/data/datasources/local_storage.dart
// Layer   : Data (data source)
// Purpose : The ONLY class that touches SharedPreferences. Stores users, posts
//           and the current session as JSON strings.
// Used by : AuthRepositoryImpl, PostRepositoryImpl
// ─────────────────────────────────────────────────────────────────────────────

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/post.dart';
import '../models/post_mapper.dart';
import '../models/user_model.dart';

class LocalStorage {
  LocalStorage._(this._prefs);

  final SharedPreferences _prefs;

  static const _usersKey = 'users';
  static const _postsKey = 'posts';
  static const _sessionKey = 'current';

  static Future<LocalStorage> create() async =>
      LocalStorage._(await SharedPreferences.getInstance());

  // ── Users ──────────────────────────────────────────────────────────────────
  List<UserModel> readUsers() {
    final raw = _prefs.getString(_usersKey);
    if (raw == null) return [];
    return (jsonDecode(raw) as List)
        .map((e) => UserModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> writeUsers(List<UserModel> users) =>
      _prefs.setString(_usersKey, jsonEncode(users.map((e) => e.toJson()).toList()));

  // ── Posts ──────────────────────────────────────────────────────────────────
  /// Returns null when nothing has ever been saved (first launch).
  List<Post>? readPosts() {
    final raw = _prefs.getString(_postsKey);
    if (raw == null) return null;
    return (jsonDecode(raw) as List)
        .map((e) => PostMapper.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> writePosts(List<Post> posts) =>
      _prefs.setString(_postsKey, jsonEncode(posts.map(PostMapper.toJson).toList()));

  // ── Session ────────────────────────────────────────────────────────────────
  String? readSession() => _prefs.getString(_sessionKey);

  Future<void> writeSession(String? username) async {
    if (username == null) {
      await _prefs.remove(_sessionKey);
    } else {
      await _prefs.setString(_sessionKey, username);
    }
  }
}
