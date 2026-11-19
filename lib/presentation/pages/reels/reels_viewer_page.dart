// ─────────────────────────────────────────────────────────────────────────────
// File    : lib/presentation/pages/reels/reels_viewer_page.dart
// Layer   : Presentation (page)
// Purpose : Full-screen reel viewer pushed when a reel is tapped in Explore or
//           Profile. Opens at the tapped reel, autoplays it WITH sound, and
//           lets the user swipe to the next one.
//           [onlyUser] limits the swipe list to one author (used from Profile).
// Opened  : via openPost() in presentation/navigation/open_post.dart
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/feed/feed_bloc.dart';
import '../../widgets/dark_media_scope.dart';
import 'reels_pager.dart';

class ReelsViewerPage extends StatelessWidget {
  const ReelsViewerPage({super.key, required this.startPostId, this.onlyUser});

  final int startPostId;
  final String? onlyUser;

  @override
  Widget build(BuildContext context) => DarkMediaScope(
    child: SafeArea(
    child: Scaffold(
          backgroundColor: Colors.black,
          body: Stack(children: [
            Positioned.fill(
              child: BlocBuilder<FeedBloc, FeedState>(builder: (context, state) {
                final reels = state.posts
                    .where((p) => p.isReel && (onlyUser == null || p.user == onlyUser))
                    .toList();
                if (reels.isEmpty) {
                  return const Center(child: Text('No reels to show'));
                }
                final start = reels.indexWhere((p) => p.id == startPostId);
                return ReelsPager(posts: reels, initialIndex: start < 0 ? 0 : start);
              }),
            ),
            Positioned(
              top: 0,
              left: 0,
              child: SafeArea(
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white, shadows: [Shadow(blurRadius: 6)]),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
          ]),
        ),
  ),
  );
}
