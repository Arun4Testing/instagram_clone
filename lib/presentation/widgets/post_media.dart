// ─────────────────────────────────────────────────────────────────────────────
// File    : lib/presentation/widgets/post_media.dart
// Layer   : Presentation (shared widget)
// Purpose : The media area of a feed card: a picture with double-tap-to-like
//           for photo posts, or an inline [ReelPlayer] for reels.
// Used by : PostCard
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import '../../domain/entities/post.dart';
import 'double_tap_heart.dart';
import 'post_image.dart';
import 'reel_player.dart';

class PostMedia extends StatelessWidget {
  const PostMedia(this.post, {super.key, this.onDoubleTap});

  final Post post;
  final VoidCallback? onDoubleTap;

  @override
  Widget build(BuildContext context) => post.isReel
      ? ReelPlayer(post: post, onDoubleTap: onDoubleTap)
      : DoubleTapHeart(onDoubleTap: onDoubleTap, child: PostImage(post: post));
}
