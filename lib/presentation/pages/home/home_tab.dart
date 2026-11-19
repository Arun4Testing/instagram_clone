// ─────────────────────────────────────────────────────────────────────────────
// File    : lib/presentation/pages/home/home_tab.dart
// Layer   : Presentation (page / bottom-nav tab)
// Purpose : The "Home" tab: top bar (create + notifications), a stories strip
//           built from the post authors, and the scrolling feed of PostCards.
//           Shows a spinner during the first load and an empty message when
//           there are no posts.
// Used by : AppShell
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/feed/feed_bloc.dart';
import '../../widgets/avatar.dart';
import '../create/create_sheet.dart';
import 'post_card.dart';

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    final me = context.select((AuthBloc bloc) => bloc.state.user?.username ?? '');

    return BlocBuilder<FeedBloc, FeedState>(builder: (context, state) {
      final others = state.posts.map((p) => p.user).where((u) => u != me).toSet().toList();

      return Column(children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(children: [
            IconButton(iconSize: 34, onPressed: () => showCreateSheet(context), icon: const Icon(Icons.add)),
            const Expanded(
              child: Center(
                child: Text(
                  AppConstants.appName,
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w700,
                    fontStyle: FontStyle.italic,
                    letterSpacing: -1,
                  ),
                ),
              ),
            ),
            IconButton(iconSize: 32, onPressed: () {}, icon: const Icon(Icons.favorite_border)),
          ]),
        ),
        Expanded(
          child: ListView(padding: EdgeInsets.zero, children: [
            SizedBox(
              height: 112,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                children: [
                  _StoryBubble(user: me, label: 'Your story', isMine: true),
                  for (var k = 0; k < others.length; k++)
                    _StoryBubble(user: others[k], label: others[k], hasRing: k == 0),
                ],
              ),
            ),
            if (state.isLoading)
              const Padding(padding: EdgeInsets.all(40), child: Center(child: CircularProgressIndicator()))
            else if (state.posts.isEmpty)
              const Padding(padding: EdgeInsets.all(40), child: Center(child: Text('No posts yet'))),
            for (final post in state.posts) PostCard(post: post, me: me),
          ]),
        ),
      ]);
    });
  }
}

class _StoryBubble extends StatelessWidget {
  const _StoryBubble({required this.user, required this.label, this.hasRing = false, this.isMine = false});

  final String user;
  final String label;
  final bool hasRing;
  final bool isMine;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: Column(children: [
          Stack(children: [
            if (hasRing)
              Avatar(user, size: 68, ring: true)
            else
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: isMine ? null : Border.all(color: Colors.white24, width: 2),
                ),
                child: Avatar(user, size: 68),
              ),
            if (isMine)
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.background, width: 2),
                  ),
                  child: const Icon(Icons.add, size: 18, color: Colors.black),
                ),
              ),
          ]),
          const SizedBox(height: 6),
          SizedBox(
            width: 78,
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, color: Colors.white70),
            ),
          ),
        ]),
      );
}
