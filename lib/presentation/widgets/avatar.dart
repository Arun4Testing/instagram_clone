// ─────────────────────────────────────────────────────────────────────────────
// File    : lib/presentation/widgets/avatar.dart
// Layer   : Presentation (shared widget)
// Purpose : Circular avatar with the user's initial on a gradient chosen from
//           the username, optionally wrapped in the story ring.
// Used by : Home, Reels, Comments, Profile, Shell
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class Avatar extends StatelessWidget {
  const Avatar(this.user, {super.key, this.size = 34, this.ring = false});

  final String user;
  final double size;
  final bool ring;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.gradients[user.hashCode.abs() % AppColors.gradients.length];
    final core = Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(colors: colors, begin: Alignment.topLeft, end: Alignment.bottomRight),
      ),
      child: Text(
        user.isEmpty ? '?' : user[0].toUpperCase(),
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: size * .42),
      ),
    );
    if (!ring) return core;
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: const BoxDecoration(shape: BoxShape.circle, gradient: AppColors.storyRing),
      child: Container(
        padding: const EdgeInsets.all(2),
        decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.background),
        child: core,
      ),
    );
  }
}
