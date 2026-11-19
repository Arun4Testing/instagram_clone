// ─────────────────────────────────────────────────────────────────────────────
// File    : lib/presentation/widgets/folio_mark.dart
// Layer   : Presentation (shared widget)
// Purpose : The app mark: a terracotta rounded square with a serif italic "F".
//           Drawn with plain widgets (no asset) and tinted by the theme.
// Used by : SplashPage, LoginPage
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import '../../core/theme/app_palette.dart';
import '../../core/theme/app_typography.dart';

class PicYapper extends StatelessWidget {
  const PicYapper(this.size, {super.key});

  final double size;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: p.accent, borderRadius: BorderRadius.circular(size * .3)),
      child: Text(
        'PY',
        style: AppTypography.serif(
          color: p.onAccent,
          fontSize: size * .62,
          fontWeight: FontWeight.w600,
          fontStyle: FontStyle.italic,
          height: 1,
        ),
      ),
    );
  }
}
