// ─────────────────────────────────────────────────────────────────────────────
// File    : lib/presentation/widgets/post_tile.dart
// Layer   : Presentation (shared widget)
// Purpose : Square grid thumbnail used by Explore and Profile. Reels get a
//           play badge. Shows a static image only (no video controller), and
//           uses HitTestBehavior.opaque so every tap on the tile is caught.
// Used by : ExploreTab, ProfileTab
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import '../../domain/entities/post.dart';
import 'post_image.dart';

class PostTile extends StatelessWidget {
  const PostTile(this.post, {super.key, required this.onTap, this.footer});

  final Post post;
  final VoidCallback onTap;
  final Widget? footer;

  @override
  Widget build(BuildContext context) => GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Stack(fit: StackFit.expand, children: [
          PostImage(post: post),
          if (post.isReel)
            const Positioned(
              top: 8,
              right: 8,
              child: Icon(Icons.smart_display, color: Colors.white, shadows: [Shadow(blurRadius: 6)]),
            ),
          if (footer != null) Positioned(left: 8, bottom: 8, child: footer!),
        ]),
      );
}
