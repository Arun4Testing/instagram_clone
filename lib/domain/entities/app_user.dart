// ─────────────────────────────────────────────────────────────────────────────
// File    : lib/domain/entities/app_user.dart
// Layer   : Domain (entity)
// Purpose : The signed-in user as the UI sees it. Deliberately has NO password
//           field - credentials never leave the data layer.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:equatable/equatable.dart';

class AppUser extends Equatable {
  const AppUser({required this.username, this.name = '', this.bio = ''});

  final String username;
  final String name;
  final String bio;

  /// Name to show in the UI; falls back to the username.
  String get displayName => name.isEmpty ? username : name;

  AppUser copyWith({String? name, String? bio}) =>
      AppUser(username: username, name: name ?? this.name, bio: bio ?? this.bio);

  @override
  List<Object?> get props => [username, name, bio];
}
