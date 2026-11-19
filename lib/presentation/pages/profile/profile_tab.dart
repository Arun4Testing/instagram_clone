// ─────────────────────────────────────────────────────────────────────────────
// File    : lib/presentation/pages/profile/profile_tab.dart
// Layer   : Presentation (page / bottom-nav tab)
// Purpose : The signed-in user's profile.
//             * Header  : username, avatar, post count, name, bio
//             * Actions : Edit profile (dialog), Share, Log out (menu)
//             * Tabs    : Posts (photos + reels)  |  Reels only  |  others
//                         (placeholders)
//             * Grid    : thumbnails only (no video decoders). Tapping a reel
//                         opens the full-screen viewer limited to this user's
//                         reels, autoplaying with sound.
// Dispatches : ProfileUpdated, LoggedOut (AuthBloc)
// Used by : AppShell
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/app_user.dart';
import '../../../domain/entities/post.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/feed/feed_bloc.dart';
import '../../navigation/open_post.dart';
import '../../widgets/avatar.dart';
import '../../widgets/post_tile.dart';
import '../create/create_sheet.dart';

class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  static const _tabIcons = [
    Icons.grid_on,
    Icons.smart_display_outlined,
    Icons.repeat,
    Icons.person_pin_outlined,
  ];

  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final user = context.select((AuthBloc bloc) => bloc.state.user);
    if (user == null) return const SizedBox.shrink();

    return BlocBuilder<FeedBloc, FeedState>(builder: (context, feed) {
      final mine = feed.posts.where((p) => p.user == user.username).toList();
      final reels = mine.where((p) => p.isReel).toList();

      return ListView(padding: EdgeInsets.zero, children: [
        _TopBar(username: user.username),
        _Header(user: user, postCount: mine.length),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
          child: Text(user.bio.isEmpty ? 'Offline' : user.bio, style: const TextStyle(fontSize: 16)),
        ),
        const _BannerChip(),
        _ActionButtons(user: user),
        _TabBar(icons: _tabIcons, selected: _tab, onSelected: (i) => setState(() => _tab = i)),
        _Content(
          tab: _tab,
          posts: _tab == 0 ? mine : reels,
          username: user.username,
        ),
      ]);
    });
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.username});

  final String username;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(14, 8, 12, 0),
        child: Row(children: [
          const Icon(Icons.lock_outline, size: 22),
          const SizedBox(width: 8),
          Text(username, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700)),
          const Icon(Icons.keyboard_arrow_down),
          const Spacer(),
          IconButton(iconSize: 34, onPressed: () => showCreateSheet(context), icon: const Icon(Icons.add)),
          IconButton(iconSize: 32, onPressed: () => _showMenu(context), icon: const Icon(Icons.menu)),
        ]),
      );

  void _showMenu(BuildContext context) {
    final auth = context.read<AuthBloc>();
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.sheet,
      builder: (sheetContext) => SafeArea(
        child: ListTile(
          leading: const Icon(Icons.logout),
          title: const Text('Log out'),
          onTap: () {
            Navigator.pop(sheetContext);
            auth.add(const LoggedOut());
          },
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.user, required this.postCount});

  final AppUser user;
  final int postCount;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
        child: Row(children: [
          Stack(clipBehavior: Clip.none, children: [
            Avatar(user.username, size: 86),
            Positioned(
              top: -24,
              left: 0,
              child: Container(
                width: 64,
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(color: AppColors.chip, borderRadius: BorderRadius.circular(16)),
                child: const Text(
                  'Try sharing a song…',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 11, color: Colors.white54),
                ),
              ),
            ),
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
          const SizedBox(width: 22),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(user.displayName, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w500)),
              const SizedBox(height: 10),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                _Stat('$postCount', 'posts'),
                const _Stat('0', 'followers'),
                const _Stat('0', 'following'),
              ]),
            ]),
          ),
        ]),
      );
}

class _Stat extends StatelessWidget {
  const _Stat(this.value, this.label);

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
        Text(label, style: const TextStyle(fontSize: 16)),
      ]);
}

class _BannerChip extends StatelessWidget {
  const _BannerChip();

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white24),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.add, size: 18, color: Colors.white70),
              SizedBox(width: 6),
              Text('Add banners', style: TextStyle(color: Colors.white70)),
            ]),
          ),
        ),
      );
}

class _ActionButtons extends StatelessWidget {
  const _ActionButtons({required this.user});

  final AppUser user;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(10, 14, 10, 8),
        child: Row(children: [
          Expanded(
            child: _ProfileButton(
              label: 'Edit profile',
              onPressed: () => showDialog<void>(
                context: context,
                builder: (_) => _EditProfileDialog(
                  initialName: user.name,
                  initialBio: user.bio,
                  authBloc: context.read<AuthBloc>(),
                ),
              ),
            ),
          ),
          const SizedBox(width: 6),
          Expanded(child: _ProfileButton(label: 'Share profile', onPressed: () {})),
          const SizedBox(width: 6),
          SizedBox(width: 54, child: _ProfileButton(icon: Icons.person_add_alt, onPressed: () {})),
        ]),
      );
}

class _ProfileButton extends StatelessWidget {
  const _ProfileButton({this.label, this.icon, required this.onPressed});

  final String? label;
  final IconData? icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => SizedBox(
        height: 42,
        child: FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.button,
            foregroundColor: Colors.white,
            padding: EdgeInsets.zero,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onPressed: onPressed,
          child: icon != null
              ? Icon(icon)
              : Text(label ?? '', style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
        ),
      );
}

class _TabBar extends StatelessWidget {
  const _TabBar({required this.icons, required this.selected, required this.onSelected});

  final List<IconData> icons;
  final int selected;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) => Row(children: [
        for (var k = 0; k < icons.length; k++)
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => onSelected(k),
              child: Container(
                height: 50,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: k == selected ? Colors.white : Colors.white12,
                      width: k == selected ? 2 : .5,
                    ),
                  ),
                ),
                child: Icon(icons[k], color: k == selected ? Colors.white : Colors.white54),
              ),
            ),
          ),
      ]);
}

class _Content extends StatelessWidget {
  const _Content({required this.tab, required this.posts, required this.username});

  final int tab;
  final List<Post> posts;
  final String username;

  @override
  Widget build(BuildContext context) {
    if (tab >= 2) {
      return const Padding(
        padding: EdgeInsets.only(top: 90),
        child: Center(child: Text('Nothing here yet', style: TextStyle(color: Colors.white54))),
      );
    }
    if (posts.isEmpty) {
      return _EmptyState(
        title: tab == 0 ? 'Create your first post' : 'Create your first reel',
        subtitle: 'Share your point of view.',
      );
    }
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: posts.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 1,
        mainAxisSpacing: 1,
        childAspectRatio: tab == 1 ? 9 / 14 : 1,
      ),
      itemBuilder: (_, k) =>
          PostTile(posts[k], onTap: () => openPost(context, posts[k], onlyUser: username)),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: 90),
        child: Column(children: [
          Text(title, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w700)),
          const SizedBox(height: 10),
          Text(subtitle, style: const TextStyle(fontSize: 18)),
          const SizedBox(height: 36),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.accent,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            onPressed: () => showCreateSheet(context),
            child: const Text('Create', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          ),
        ]),
      );
}

class _EditProfileDialog extends StatefulWidget {
  const _EditProfileDialog({
    required this.initialName,
    required this.initialBio,
    required this.authBloc,
  });

  final String initialName;
  final String initialBio;
  final AuthBloc authBloc;

  @override
  State<_EditProfileDialog> createState() => _EditProfileDialogState();
}

class _EditProfileDialogState extends State<_EditProfileDialog> {
  late final _name = TextEditingController(text: widget.initialName);
  late final _bio = TextEditingController(text: widget.initialBio);

  @override
  void dispose() {
    _name.dispose();
    _bio.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
        backgroundColor: AppColors.sheet,
        title: const Text('Edit profile'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: _name, decoration: const InputDecoration(labelText: 'Name')),
          TextField(controller: _bio, decoration: const InputDecoration(labelText: 'Bio')),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              widget.authBloc.add(ProfileUpdated(name: _name.text.trim(), bio: _bio.text.trim()));
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      );
}
