// ─────────────────────────────────────────────────────────────────────────────
// File    : lib/presentation/pages/profile/profile_tab.dart
// Layer   : Presentation (page / bottom-nav tab)
// Purpose : The signed-in user's profile.
//             * Header  : username, avatar, post count, name, bio
//             * Actions : Edit profile (dialog), Share, Settings sheet
//                         (Appearance: system / light / dark, and Log out)
//             * Tabs    : Posts (photos + reels)  |  Reels only  |  others
//                         (placeholders)
//             * Grid    : thumbnails only (no video decoders). Tapping a reel
//                         opens the full-screen viewer limited to this user's
//                         reels, autoplaying with sound.
// Dispatches : ProfileUpdated, LoggedOut (AuthBloc); setMode (ThemeCubit)
// Used by : AppShell
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/app_typography.dart';
import '../../../domain/entities/app_theme_mode.dart';
import '../../../domain/entities/app_user.dart';
import '../../../domain/entities/post.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/feed/feed_bloc.dart';
import '../../blocs/theme/theme_cubit.dart';
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
          child: Text(user.bio.isEmpty ? 'No bio yet' : user.bio, style: const TextStyle(fontSize: 16)),
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
          Text(username, style: AppTypography.serif(fontSize: 26, fontWeight: FontWeight.w600)),
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
      builder: (sheetContext) => SafeArea(
        child: _SettingsSheet(
          onLogOut: () {
            Navigator.pop(sheetContext);
            auth.add(const LoggedOut());
          },
        ),
      ),
    );
  }
}

/// Bottom sheet opened from the profile menu: appearance + log out.
class _SettingsSheet extends StatelessWidget {
  const _SettingsSheet({required this.onLogOut});

  final VoidCallback onLogOut;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Settings', style: AppTypography.serif(fontSize: 24, fontWeight: FontWeight.w600)),
        const SizedBox(height: 22),
        Text('Appearance', style: TextStyle(color: p.muted, fontWeight: FontWeight.w600)),
        const SizedBox(height: 10),
        BlocBuilder<ThemeCubit, AppThemeMode>(
          builder: (context, mode) => SizedBox(
            width: double.infinity,
            child: SegmentedButton<AppThemeMode>(
              showSelectedIcon: false,
              segments: const [
                ButtonSegment(
                    value: AppThemeMode.system, icon: Icon(Icons.brightness_auto_outlined), label: Text('System')),
                ButtonSegment(
                    value: AppThemeMode.light, icon: Icon(Icons.light_mode_outlined), label: Text('Light')),
                ButtonSegment(value: AppThemeMode.dark, icon: Icon(Icons.dark_mode_outlined), label: Text('Dark')),
              ],
              selected: {mode},
              onSelectionChanged: (selection) => context.read<ThemeCubit>().setMode(selection.first),
            ),
          ),
        ),
        const SizedBox(height: 14),
        const Divider(),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.logout),
          title: const Text('Log out'),
          onTap: onLogOut,
        ),
      ]),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.user, required this.postCount});

  final AppUser user;
  final int postCount;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Padding(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
        child: Row(children: [
          Stack(clipBehavior: Clip.none, children: [
            Avatar(user.username, size: 86),
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: p.accent,
                  shape: BoxShape.circle,
                  border: Border.all(color: p.background, width: 2),
                ),
                child: Icon(Icons.add, size: 16, color: p.onAccent),
              ),
            ),
          ]),
          const SizedBox(width: 22),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(user.displayName, style: AppTypography.serif(fontSize: 19, fontWeight: FontWeight.w600)),
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
}

class _Stat extends StatelessWidget {
  const _Stat(this.value, this.label);

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(value, style: AppTypography.serif(fontSize: 20, fontWeight: FontWeight.w600)),
        Text(label, style: TextStyle(fontSize: 14, color: context.palette.muted)),
      ]);
}

class _BannerChip extends StatelessWidget {
  const _BannerChip();

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              border: Border.all(color: p.border),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.add, size: 18, color: p.muted),
              const SizedBox(width: 6),
              Text('Add a link', style: TextStyle(color: p.muted)),
            ]),
          ),
        ),
      );
  }
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
            backgroundColor: context.palette.surfaceAlt,
            foregroundColor: context.palette.text,
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
  Widget build(BuildContext context) {
    final p = context.palette;
    return Row(children: [
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
                      color: k == selected ? p.text : p.border,
                      width: k == selected ? 2 : .5,
                    ),
                  ),
                ),
                child: Icon(icons[k], color: k == selected ? p.text : p.subtle),
              ),
            ),
          ),
      ]);
  }
}

class _Content extends StatelessWidget {
  const _Content({required this.tab, required this.posts, required this.username});

  final int tab;
  final List<Post> posts;
  final String username;

  @override
  Widget build(BuildContext context) {
    if (tab >= 2) {
      return Padding(
        padding: const EdgeInsets.only(top: 90),
        child: Center(child: Text('Nothing here yet', style: TextStyle(color: context.palette.muted))),
      );
    }
    if (posts.isEmpty) {
      return _EmptyState(
        title: tab == 0 ? 'Create your first post' : 'Create your first yapp',
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
          Text(title, style: AppTypography.serif(fontSize: 26, fontWeight: FontWeight.w600)),
          const SizedBox(height: 10),
          Text(subtitle, style: TextStyle(fontSize: 17, color: context.palette.muted)),
          const SizedBox(height: 36),
          FilledButton(
            style: FilledButton.styleFrom(
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
        backgroundColor: context.palette.surface,
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
