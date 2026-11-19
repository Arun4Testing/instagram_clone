// ─────────────────────────────────────────────────────────────────────────────
// File    : lib/domain/entities/post.dart
// Layer   : Domain (entity)
// Purpose : A feed item - either a photo post or a reel.
//           * Photo post : [image] holds the base64 JPEG.
//           * Reel       : [video] holds the stored file NAME and [image]
//                          holds a base64 JPEG THUMBNAIL (so grids never have
//                          to open a video decoder just to show a preview).
// ─────────────────────────────────────────────────────────────────────────────

import 'package:equatable/equatable.dart';
import 'comment.dart';

class Post extends Equatable {
  const Post({
    required this.id,
    required this.user,
    required this.caption,
    required this.timestamp,
    this.image,
    this.video,
    this.seed = 0,
    this.likes = const [],
    this.comments = const [],
  });

  final int id;
  final String user;
  final String caption;
  final int timestamp;
  final String? image;
  final String? video;

  /// Picks a placeholder gradient for seed posts that have no picture.
  final int seed;
  final List<String> likes;
  final List<Comment> comments;

  bool get isReel => video != null;
  bool isLikedBy(String username) => likes.contains(username);

  Post copyWith({List<String>? likes, List<Comment>? comments, String? image}) => Post(
        id: id,
        user: user,
        caption: caption,
        timestamp: timestamp,
        image: image ?? this.image,
        video: video,
        seed: seed,
        likes: likes ?? this.likes,
        comments: comments ?? this.comments,
      );

  @override
  List<Object?> get props => [id, likes, comments, image];
}
