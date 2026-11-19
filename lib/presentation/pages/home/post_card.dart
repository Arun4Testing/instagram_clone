// ─────────────────────────────────────────────────────────────────────────────
// File    : lib/presentation/pages/home/post_card.dart
// Layer   : Presentation (page widget)
// Purpose : One feed entry, laid out like a magazine spread: author row, rounded
//           media (photo or inline reel), action buttons, like count, serif
//           caption, comment link, relative time and a hairline divider.
// Dispatches : LikeToggled (FeedBloc); opens the comments sheet.
// Used by : HomeTab
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/app_typography.dart';
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
    final p = context.palette;
    final liked = post.isLikedBy(me);
    final bloc = context.read<FeedBloc>();
    void toggleLike() => bloc.add(LikeToggled(postId: post.id, username: me));

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 4, 10),
        child: Row(children: [
          Avatar(post.user, size: 38),
          const SizedBox(width: 10),
          Expanded(
            child: Text(post.user, style: AppTypography.serif(fontSize: 17, fontWeight: FontWeight.w600)),
          ),
          IconButton(onPressed: () {}, icon: const Icon(Icons.more_horiz)),
        ]),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: AspectRatio(
            aspectRatio: 4 / 5,
            child: PostMedia(post, onDoubleTap: () {
              if (!liked) toggleLike();
            }),
          ),
        ),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Row(children: [
          IconButton(
            iconSize: 28,
            onPressed: toggleLike,
            icon: Icon(
              liked ? Icons.favorite : Icons.favorite_border,
              color: liked ? p.accent : p.text,
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
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text.rich(TextSpan(
            style: AppTypography.serif(fontSize: 15, height: 1.35, color: p.text),
            children: [
              TextSpan(text: '${post.user}  ', style: const TextStyle(fontWeight: FontWeight.w700)),
              TextSpan(text: post.caption),
            ],
          )),
          const SizedBox(height: 6),
          GestureDetector(
            onTap: () => showCommentsSheet(context, post.id),
            child: Text(
              post.comments.isEmpty ? 'Add a comment…' : 'View all ${post.comments.length} comments',
              style: TextStyle(color: p.muted),
            ),
          ),
          const SizedBox(height: 4),
          Text(longAgo(post.timestamp), style: TextStyle(color: p.subtle, fontSize: 12)),
          const SizedBox(height: 18),
          const Divider(),
          const SizedBox(height: 6),
        ]),
      ),
    ]);
  }
}
