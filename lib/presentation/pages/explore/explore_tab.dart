// ─────────────────────────────────────────────────────────────────────────────
// File    : lib/presentation/pages/explore/explore_tab.dart
// Layer   : Presentation (page / bottom-nav tab)
// Purpose : The "Search" tab: a search box (matches username or caption) over a
//           3-column grid. Reels are listed first, then photos; decorative
//           filler tiles pad the grid when the search box is empty.
//           Tapping a reel opens the full-screen viewer (autoplay + sound);
//           tiles show thumbnails only, so no video decoders are used here.
// Used by : AppShell
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../blocs/feed/feed_bloc.dart';
import '../../navigation/open_post.dart';
import '../../widgets/post_tile.dart';

class ExploreTab extends StatefulWidget {
  const ExploreTab({super.key});

  @override
  State<ExploreTab> createState() => _ExploreTabState();
}

class _ExploreTabState extends State<ExploreTab> {
  static const _fillerTileCount = 12;
  static const _viewCounts = ['755K', '1.4M', '614K', '1.4M', '1M', '784K', '912K', '136K', '1.6M', '2.5M', '100K', '8.9M'];

  String _query = '';

  @override
  Widget build(BuildContext context) => BlocBuilder<FeedBloc, FeedState>(builder: (context, state) {
        final q = _query.trim().toLowerCase();
        final ordered = [...state.posts.where((p) => p.isReel), ...state.posts.where((p) => !p.isReel)];
        final real = ordered
            .where((p) => q.isEmpty || p.user.toLowerCase().contains(q) || p.caption.toLowerCase().contains(q))
            .toList();
        final filler = q.isEmpty ? _fillerTileCount : 0;

        return Column(children: [
          _SearchBar(onChanged: (value) => setState(() => _query = value)),
          Expanded(
            child: real.isEmpty && filler == 0
                ? const Center(child: Text('No results', style: TextStyle(color: Colors.white54)))
                : GridView.builder(
                    padding: EdgeInsets.zero,
                    itemCount: real.length + filler,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 1,
                      mainAxisSpacing: 1,
                      childAspectRatio: .75,
                    ),
                    itemBuilder: (_, k) {
                      final footer = _ViewCount(_viewCounts[k % _viewCounts.length]);
                      if (k < real.length) {
                        return PostTile(real[k], footer: footer, onTap: () => openPost(context, real[k]));
                      }
                      return Stack(fit: StackFit.expand, children: [
                        DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: AppColors.gradients[(k * 7) % AppColors.gradients.length],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                        ),
                        Positioned(left: 8, bottom: 8, child: footer),
                      ]);
                    },
                  ),
          ),
        ]);
      });
}

class _SearchBar extends StatelessWidget {
  const _SearchBar({required this.onChanged});

  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(10, 10, 14, 10),
        child: Row(children: [
          Expanded(
            child: TextField(
              onChanged: onChanged,
              style: const TextStyle(fontSize: 18),
              decoration: InputDecoration(
                hintText: 'Search',
                hintStyle: const TextStyle(color: Colors.white54),
                prefixIcon: const Icon(Icons.search, color: Colors.white70),
                filled: true,
                fillColor: AppColors.button,
                contentPadding: const EdgeInsets.symmetric(vertical: 16),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
              ),
            ),
          ),
          const SizedBox(width: 14),
          const Icon(Icons.bookmark_border, size: 32),
        ]),
      );
}

class _ViewCount extends StatelessWidget {
  const _ViewCount(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Row(children: [
        const Icon(Icons.remove_red_eye_outlined, size: 18),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(fontWeight: FontWeight.w600, shadows: [Shadow(blurRadius: 4)])),
      ]);
}
