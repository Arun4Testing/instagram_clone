// ─────────────────────────────────────────────────────────────────────────────
// File    : lib/core/theme/app_colors.dart
// Layer   : Core
// Purpose : Colours that do NOT change with light/dark mode: avatar and
//           placeholder gradients and the "new story" ring. Everything that
//           does change lives in AppPalette (app_palette.dart).
// Used by : Avatar, PostImage, ExploreTab
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  /// Muted, earthy gradient pairs for avatars and posts without a picture.
  /// Mid-tones, so white initials stay readable in both themes.
  static const List<List<Color>> gradients = [
    [Color(0xFFD9A066), Color(0xFFB4532F)], // ochre → terracotta
    [Color(0xFF8FA37C), Color(0xFF5E7A63)], // sage
    [Color(0xFFC98B9A), Color(0xFF8E4F6B)], // dusty rose → plum
    [Color(0xFF7FA1B3), Color(0xFF486B84)], // slate blue
    [Color(0xFFD6B26A), Color(0xFFA7803A)], // mustard
    [Color(0xFFA78A7A), Color(0xFF6E5246)], // clay
  ];

  /// Ring around an avatar that has something new.
  static const LinearGradient storyRing = LinearGradient(
    begin: Alignment.bottomLeft,
    end: Alignment.topRight,
    colors: [Color(0xFFD4A24C), Color(0xFFB4532F), Color(0xFF7A3E54)],
  );
}
