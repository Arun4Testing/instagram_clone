// ─────────────────────────────────────────────────────────────────────────────
// File    : lib/presentation/pages/shell/app_shell.dart
// Layer   : Presentation (page)
// Purpose : Main scaffold after login: the five tabs plus the bottom
//           navigation bar (Home, Reels, Messages, Search, Profile avatar).
//
// Video note: tabs live in an IndexedStack so they keep their state. Each tab
//           is also wrapped in an explicit TickerMode(enabled: selected).
//           ReelPlayer listens to TickerMode, so a reel in a hidden tab
//           pauses (no audio from background tabs) and resumes when shown.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_palette.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../widgets/avatar.dart';
import '../explore/explore_tab.dart';
import '../home/home_tab.dart';
import '../profile/profile_tab.dart';
import '../reels/reels_tab.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  static const _profileIndex = 4;

static const _navIcons = [
  [Icons.dynamic_feed_outlined, Icons.dynamic_feed],     // 0: Feed / Streams
  [Icons.play_circle_outline, Icons.play_circle],        // 1: Video / Clips
  [Icons.chat_bubble_outline, Icons.chat_bubble],        // 2: Messages / Chat
  [Icons.explore_outlined, Icons.explore],               // 3: Discover / Explore
];
  static const _tabs = <Widget>[
    HomeTab(),
    ReelsTab(),
    _ComingSoonTab('Messages'),
    ExploreTab(),
    ProfileTab(),
  ];

  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final me = context.select((AuthBloc bloc) => bloc.state.user?.username ?? '');
    final p = context.palette;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: IndexedStack(
          index: _index,
          children: [
            for (var k = 0; k < _tabs.length; k++) TickerMode(enabled: k == _index, child: _tabs[k]),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: p.background,
          border: Border(top: BorderSide(color: p.border, width: .5)),
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 56,
            child: Row(children: [
              for (var k = 0; k < _navIcons.length; k++)
                Expanded(
                  child: IconButton(
                    iconSize: 28,
                    onPressed: () => setState(() => _index = k),
                    icon: Icon(_navIcons[k][_index == k ? 1 : 0], color: _index == k ? p.text : p.muted),
                  ),
                ),
              Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => setState(() => _index = _profileIndex),
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.all(1.5),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(Avatar.cornerFor(34)),
                        border: Border.all(
                          color: _index == _profileIndex ? p.text : Colors.transparent,
                          width: 1.5,
                        ),
                      ),
                      child: Avatar(me, size: 28),
                    ),
                  ),
                ),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}

class _ComingSoonTab extends StatelessWidget {
  const _ComingSoonTab(this.title);

  final String title;

  @override
  Widget build(BuildContext context) =>
      Center(child: Text('$title coming soon', style: TextStyle(color: context.palette.muted)));
}
