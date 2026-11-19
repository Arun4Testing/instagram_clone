// ─────────────────────────────────────────────────────────────────────────────
// File    : lib/presentation/widgets/avatar.dart
// Layer   : Presentation (shared widget)
// Purpose : Rounded-square avatar with the user's initial (serif) on an earthy
//           gradient chosen from the username, optionally wrapped in the
//           "new story" ring.
// Used by : Home, Reels, Comments, Profile, Shell
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_palette.dart';
import '../../core/theme/app_typography.dart';

class Avatar extends StatelessWidget {
  const Avatar(this.user, {super.key, this.size = 34, this.ring = false});

  final String user;
  final double size;
  final bool ring;

  /// Corner radius for a square of [size]; shared so borders drawn around an
  /// avatar can match its shape.
  static double cornerFor(double size) => size * .32;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.gradients[user.hashCode.abs() % AppColors.gradients.length];
    final core = Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(cornerFor(size)),
        gradient: LinearGradient(colors: colors, begin: Alignment.topLeft, end: Alignment.bottomRight),
      ),
      child: Text(
        user.isEmpty ? '?' : user[0].toUpperCase(),
        style: AppTypography.serif(color: Colors.white, fontWeight: FontWeight.w600, fontSize: size * .46),
      ),
    );
    if (!ring) return core;
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(cornerFor(size + 10)),
        gradient: AppColors.storyRing,
      ),
      child: Container(
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(cornerFor(size + 4)),
          color: context.palette.background,
        ),
        child: core,
      ),
    );
  }
}
