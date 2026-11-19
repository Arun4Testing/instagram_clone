// ─────────────────────────────────────────────────────────────────────────────
// File    : lib/presentation/pages/create/create_sheet.dart
// Layer   : Presentation (page / bottom sheet)
// Purpose : The "Create" menu (Reel, Post, Story, ...). Reel and Post open
//           their editors; the rest show a "coming soon" message.
// Opened  : showCreateSheet(context) from Home, Profile and Reels tabs
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import 'create_post_page.dart';
import 'create_reel_page.dart';

enum _CreateType { reel, edits, post, story, highlights, live }

class _CreateOption {
  const _CreateOption(this.type, this.icon, this.label, {this.isNew = false});

  final _CreateType type;
  final IconData icon;
  final String label;
  final bool isNew;
}

const _options = [
  _CreateOption(_CreateType.reel, Icons.smart_display_outlined, 'Reel'),
  _CreateOption(_CreateType.edits, Icons.vertical_split_outlined, 'Edits', isNew: true),
  _CreateOption(_CreateType.post, Icons.grid_on, 'Post'),
  _CreateOption(_CreateType.story, Icons.add_circle_outline, 'Story'),
  _CreateOption(_CreateType.highlights, Icons.favorite_border, 'Highlights'),
  _CreateOption(_CreateType.live, Icons.sensors, 'Live'),
];

void showCreateSheet(BuildContext context) {
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: AppColors.sheet,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
    builder: (sheetContext) => SafeArea(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const SizedBox(height: 10),
        Container(
          width: 40,
          height: 4,
          decoration: BoxDecoration(color: Colors.white38, borderRadius: BorderRadius.circular(4)),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 16),
          child: Text('Create', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
        ),
        const Divider(height: 1, color: Colors.white12),
        for (final option in _options)
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            leading: Icon(option.icon, size: 30),
            title: Text(option.label, style: const TextStyle(fontSize: 18)),
            trailing: option.isNew
                ? Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.accent,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text('New', style: TextStyle(fontSize: 13)),
                  )
                : null,
            onTap: () {
              Navigator.pop(sheetContext);
              _open(context, option);
            },
          ),
      ]),
    ),
  );
}

void _open(BuildContext context, _CreateOption option) {
  switch (option.type) {
    case _CreateType.post:
      Navigator.push(context, MaterialPageRoute<void>(builder: (_) => const CreatePostPage()));
      break;
    case _CreateType.reel:
      Navigator.push(context, MaterialPageRoute<void>(builder: (_) => const CreateReelPage()));
      break;
    default:
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${option.label} coming soon')));
  }
}
