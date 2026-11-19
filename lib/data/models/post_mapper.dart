// ─────────────────────────────────────────────────────────────────────────────
// File    : lib/data/models/post_mapper.dart
// Layer   : Data (model)
// Purpose : JSON <-> domain conversion for [Post] and [Comment], keeping
//           serialization out of the domain entities.
//           Keys are unchanged from the previous version (id, u, c, img, vid,
//           seed, ts, l, cm) so previously saved posts remain readable.
// ─────────────────────────────────────────────────────────────────────────────

import '../../domain/entities/comment.dart';
import '../../domain/entities/post.dart';

class PostMapper {
  PostMapper._();

  static Post fromJson(Map<String, dynamic> json) => Post(
        id: json['id'] as int,
        user: json['u'] as String,
        caption: json['c'] as String,
        image: json['img'] as String?,
        video: json['vid'] as String?,
        seed: (json['seed'] as int?) ?? 0,
        timestamp: json['ts'] as int,
        likes: List<String>.from(json['l'] as List),
        comments: (json['cm'] as List)
            .map((e) => _commentFromJson(e as Map<String, dynamic>))
            .toList(),
      );

  static Map<String, dynamic> toJson(Post post) => {
        'id': post.id,
        'u': post.user,
        'c': post.caption,
        'img': post.image,
        'vid': post.video,
        'seed': post.seed,
        'ts': post.timestamp,
        'l': post.likes,
        'cm': post.comments.map(_commentToJson).toList(),
      };

  static Comment _commentFromJson(Map<String, dynamic> json) => Comment(
        user: json['u'] as String,
        text: json['t'] as String,
        timestamp: json['ts'] as int,
      );

  static Map<String, dynamic> _commentToJson(Comment c) =>
      {'u': c.user, 't': c.text, 'ts': c.timestamp};
}
