// ─────────────────────────────────────────────────────────────────────────────
// File    : lib/data/models/user_model.dart
// Layer   : Data (model)
// Purpose : Storage representation of a user, INCLUDING the password.
//           Converted to the password-free domain [AppUser] via toEntity().
//           JSON keys (u, p, n, b) are unchanged so old saved data still loads.
// ─────────────────────────────────────────────────────────────────────────────

import '../../domain/entities/app_user.dart';

class UserModel {
  const UserModel({
    required this.username,
    required this.password,
    this.name = '',
    this.bio = '',
  });

  final String username;
  final String password;
  final String name;
  final String bio;

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        username: json['u'] as String,
        password: json['p'] as String,
        name: (json['n'] as String?) ?? '',
        bio: (json['b'] as String?) ?? '',
      );

  Map<String, dynamic> toJson() => {'u': username, 'p': password, 'n': name, 'b': bio};

  UserModel copyWith({String? name, String? bio}) => UserModel(
        username: username,
        password: password,
        name: name ?? this.name,
        bio: bio ?? this.bio,
      );

  AppUser toEntity() => AppUser(username: username, name: name, bio: bio);
}
