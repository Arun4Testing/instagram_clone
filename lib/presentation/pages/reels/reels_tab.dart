// ─────────────────────────────────────────────────────────────────────────────
// File    : lib/presentation/pages/reels/reels_tab.dart
// Layer   : Presentation (page / bottom-nav tab)
// Purpose : The "Reels" tab: a full-screen pager of every reel, or an empty
//           state with a "Create a reel" button.
// Used by : AppShell
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../blocs/feed/feed_bloc.dart';
import '../create/create_sheet.dart';
import 'reels_pager.dart';

class ReelsTab extends StatelessWidget {
  const ReelsTab({super.key});

  @override
  Widget build(BuildContext context) => BlocBuilder<FeedBloc, FeedState>(builder: (context, state) {
        final reels = state.posts.where((p) => p.isReel).toList();
        if (reels.isEmpty) {
          return Center(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.smart_display_outlined, size: 64, color: Colors.white54),
              const SizedBox(height: 12),
              const Text('No reels yet', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
              const SizedBox(height: 20),
              FilledButton(
                style: FilledButton.styleFrom(backgroundColor: AppColors.accent),
                onPressed: () => showCreateSheet(context),
                child: const Text('Create a reel'),
              ),
            ]),
          );
        }
        return ReelsPager(posts: reels);
      });
}
