// ─────────────────────────────────────────────────────────────────────────────
// File    : lib/presentation/widgets/dark_media_scope.dart
// Layer   : Presentation (shared widget)
// Purpose : Full-screen video always sits on black, so its overlay text and
//           icons must stay light even when the app is in light mode. This
//           forces the dark theme (and light status-bar icons) for its child.
// Used by : ReelsPager, ReelsViewerPage
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_theme.dart';

class DarkMediaScope extends StatelessWidget {
  const DarkMediaScope({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => Theme(
        data: AppTheme.dark,
        child: AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle.light.copyWith(statusBarColor: Colors.transparent),
          child: child,
        ),
      );
}
