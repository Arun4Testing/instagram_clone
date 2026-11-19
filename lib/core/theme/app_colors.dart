// ─────────────────────────────────────────────────────────────────────────────
// File    : lib/core/theme/app_colors.dart
// Layer   : Core
// Purpose : Single source of truth for every colour and gradient in the app.
//           Replaces the old top-level constants (kBg, kSheet, kBtn, ...).
// Used by : Theme and all presentation widgets/pages
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color background = Color(0xFF0C1014);
  static const Color sheet = Color(0xFF1F2023);
  static const Color button = Color(0xFF262A30);
  static const Color primary = Color(0xFF0064E0);
  static const Color accent = Color(0xFF4A5CFF);
  static const Color accentDisabled = Color(0xFF2B3A8C);
  static const Color link = Color(0xFF3797F0);
  static const Color chip = Color(0xFF2A2D33);
  static const Color splashBackground = Color(0xFF1B1B1B);
  static const Color authBackground = Color(0xFF1F1F1F);

  /// Gradients used for avatars and for posts that have no picture.
  static const List<List<Color>> gradients = [
    [Color(0xFFF6D365), Color(0xFFFDA085)],
    [Color(0xFF667EEA), Color(0xFF764BA2)],
    [Color(0xFFFF9A9E), Color(0xFFFAD0C4)],
    [Color(0xFF43E97B), Color(0xFF38F9D7)],
    [Color(0xFF4FACFE), Color(0xFF00F2FE)],
    [Color(0xFFFA709A), Color(0xFFFEE140)],
  ];

  /// Instagram-style ring around an avatar with an unseen story.
  static const LinearGradient storyRing = LinearGradient(
    begin: Alignment.bottomLeft,
    end: Alignment.topRight,
    colors: [Color(0xFFFFC800), Color(0xFFFF0069), Color(0xFFD300C5)],
  );
}
