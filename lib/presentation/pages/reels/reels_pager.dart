// ─────────────────────────────────────────────────────────────────────────────
// File    : lib/presentation/pages/reels/reels_pager.dart
// Layer   : Presentation (page widget)
// Purpose : Vertical full-screen pager of reels (swipe up/down).
//           Tracks which page is current and passes `isCurrent` to each
//           player, so ONLY the visible reel plays (and makes sound); the
//           neighbour that is pre-loaded while swiping stays paused.
//           Also draws the Instagram-style overlay: author, caption, like /
//           comment / share buttons.
// Used by : ReelsTab, ReelsViewerPage
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/post.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/feed/feed_bloc.dart';
import '../../widgets/avatar.dart';
import '../../widgets/reel_player.dart';
import '../comments/comments_sheet.dart';

class ReelsPager extends StatefulWidget {
  const ReelsPager({super.key, required this.posts, this.initialIndex = 0});

  final List<Post> posts;
  final int initialIndex;

  @override
  State<ReelsPager> createState() => _ReelsPagerState();
}

class _ReelsPagerState extends State<ReelsPager> {
  late final PageController _controller = PageController(initialPage: widget.initialIndex);
  late int _current = widget.initialIndex;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => PageView.builder(
        controller: _controller,
        scrollDirection: Axis.vertical,
        itemCount: widget.posts.length,
        onPageChanged: (index) => setState(() => _current = index),
        itemBuilder: (_, index) => _ReelItem(
          key: ValueKey(widget.posts[index].id),
          post: widget.posts[index],
          isCurrent: index == _current,
        ),
      );
}

class _ReelItem extends StatelessWidget {
  const _ReelItem({super.key, required this.post, required this.isCurrent});

  final Post post;
  final bool isCurrent;

  @override
  Widget build(BuildContext context) {
    final me = context.read<AuthBloc>().state.user?.username ?? '';
    final bloc = context.read<FeedBloc>();
    final liked = post.isLikedBy(me);

    return Stack(fit: StackFit.expand, children: [
      ReelPlayer(
        post: post,
        isCurrent: isCurrent,
        fullScreen: true,
        onDoubleTap: () {
          if (!liked) bloc.add(LikeToggled(postId: post.id, username: me));
        },
      ),
      const IgnorePointer(
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.transparent, Colors.black54],
              stops: [.6, 1],
            ),
          ),
        ),
      ),
      Positioned(
        left: 14,
        right: 90,
        bottom: 24,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(children: [
              Avatar(post.user, size: 34),
              const SizedBox(width: 10),
              Text(post.user, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
            ]),
            if (post.caption.isNotEmpty)
              Padding(padding: const EdgeInsets.only(top: 8), child: Text(post.caption)),
          ],
        ),
      ),
      Positioned(
        right: 6,
        bottom: 20,
        child: Column(children: [
          _ActionButton(
            icon: liked ? Icons.favorite : Icons.favorite_border,
            label: '${post.likes.length}',
            color: liked ? Colors.redAccent : Colors.white,
            onPressed: () => bloc.add(LikeToggled(postId: post.id, username: me)),
          ),
          _ActionButton(
            icon: Icons.mode_comment_outlined,
            label: '${post.comments.length}',
            onPressed: () => showCommentsSheet(context, post.id),
          ),
          _ActionButton(icon: Icons.send_outlined, label: '', onPressed: () {}),
        ]),
      ),
    ]);
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.color = Colors.white,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 18),
        child: Column(children: [
          IconButton(
            iconSize: 32,
            onPressed: onPressed,
            icon: Icon(icon, color: color, shadows: const [Shadow(blurRadius: 6)]),
          ),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600, shadows: [Shadow(blurRadius: 6)])),
        ]),
      );
}
