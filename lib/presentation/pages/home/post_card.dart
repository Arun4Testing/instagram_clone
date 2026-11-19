// ─────────────────────────────────────────────────────────────────────────────
// File    : lib/presentation/pages/home/post_card.dart
// Layer   : Presentation (page widget)
// Purpose : One feed card: author row, media (photo or inline reel), action
//           buttons, like count, caption, comment link and relative time.
// Dispatches : LikeToggled (FeedBloc); opens the comments sheet.
// Used by : HomeTab
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/utils/time_ago.dart';
import '../../../domain/entities/post.dart';
import '../../blocs/feed/feed_bloc.dart';
import '../../widgets/avatar.dart';
import '../../widgets/post_media.dart';
import '../comments/comments_sheet.dart';

class PostCard extends StatelessWidget {
  const PostCard({super.key, required this.post, required this.me});

  final Post post;
  final String me;

  @override
  Widget build(BuildContext context) {
    final liked = post.isLikedBy(me);
    final bloc = context.read<FeedBloc>();
    void toggleLike() => bloc.add(LikeToggled(postId: post.id, username: me));

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(12, 10, 4, 10),
        child: Row(children: [
          Avatar(post.user, size: 36),
          const SizedBox(width: 10),
          Expanded(child: Text(post.user, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600))),
          IconButton(onPressed: () {}, icon: const Icon(Icons.more_vert)),
        ]),
      ),
      AspectRatio(
        aspectRatio: 4 / 5,
        child: PostMedia(post, onDoubleTap: () {
          if (!liked) toggleLike();
        }),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Row(children: [
          IconButton(
            iconSize: 28,
            onPressed: toggleLike,
            icon: Icon(
              liked ? Icons.favorite : Icons.favorite_border,
              color: liked ? Colors.redAccent : Colors.white,
            ),
          ),
          IconButton(
            iconSize: 26,
            onPressed: () => showCommentsSheet(context, post.id),
            icon: const Icon(Icons.mode_comment_outlined),
          ),
          IconButton(iconSize: 26, onPressed: () {}, icon: const Icon(Icons.send_outlined)),
          const Spacer(),
          IconButton(iconSize: 28, onPressed: () {}, icon: const Icon(Icons.bookmark_border)),
        ]),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(
            '${post.likes.length} like${post.likes.length == 1 ? '' : 's'}',
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text.rich(TextSpan(children: [
            TextSpan(text: '${post.user} ', style: const TextStyle(fontWeight: FontWeight.w700)),
            TextSpan(text: post.caption),
          ])),
          const SizedBox(height: 4),
          GestureDetector(
            onTap: () => showCommentsSheet(context, post.id),
            child: Text(
              post.comments.isEmpty ? 'Add a comment…' : 'View all ${post.comments.length} comments',
              style: const TextStyle(color: Colors.white54),
            ),
          ),
          const SizedBox(height: 4),
          Text(longAgo(post.timestamp), style: const TextStyle(color: Colors.white38, fontSize: 12)),
          const SizedBox(height: 18),
        ]),
      ),
    ]);
  }
}
