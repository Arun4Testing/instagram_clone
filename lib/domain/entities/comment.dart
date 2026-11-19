// ─────────────────────────────────────────────────────────────────────────────
// File    : lib/domain/entities/comment.dart
// Layer   : Domain (entity)
// Purpose : A single comment on a post.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:equatable/equatable.dart';

class Comment extends Equatable {
  const Comment({required this.user, required this.text, required this.timestamp});

  final String user;
  final String text;

  /// Milliseconds since epoch.
  final int timestamp;

  @override
  List<Object?> get props => [user, text, timestamp];
}
