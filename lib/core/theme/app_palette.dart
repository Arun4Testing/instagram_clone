// ─────────────────────────────────────────────────────────────────────────────
// File    : lib/core/theme/app_palette.dart
// Layer   : Core
// Purpose : The themed colours. One AppPalette for light, one for dark, both
//           attached to ThemeData as a ThemeExtension. Widgets read them with
//           `context.palette.xxx`, so they follow the active theme and never
//           hardcode Colors.white / Colors.black.
// Used by : AppTheme and every presentation widget that needs a colour
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';

@immutable
class AppPalette extends ThemeExtension<AppPalette> {
  const AppPalette({
    required this.background,
    required this.surface,
    required this.surfaceAlt,
    required this.text,
    required this.muted,
    required this.subtle,
    required this.border,
    required this.accent,
    required this.onAccent,
    required this.accentDisabled,
    required this.link,
  });

  /// Page background.
  final Color background;

  /// Sheets and dialogs.
  final Color surface;

  /// Buttons, chips, search field, empty image slots.
  final Color surfaceAlt;

  /// Primary text and icons.
  final Color text;

  /// Secondary text.
  final Color muted;

  /// Hints, timestamps, inactive icons.
  final Color subtle;

  /// Hairlines and outlines.
  final Color border;

  /// Brand colour (terracotta).
  final Color accent;
  final Color onAccent;
  final Color accentDisabled;

  /// Tappable text.
  final Color link;

  /// Warm paper-and-ink look.
  static const light = AppPalette(
    background: Color(0xFFFAF6EF),
    surface: Color(0xFFF3ECE0),
    surfaceAlt: Color(0xFFEAE0D0),
    text: Color(0xFF2B2420),
    muted: Color(0xFF7A6D61),
    subtle: Color(0xFFA69A8C),
    border: Color(0xFFDDD1BF),
    accent: Color(0xFFB4532F),
    onAccent: Color(0xFFFFFAF3),
    accentDisabled: Color(0xFFDDB1A0),
    link: Color(0xFF9A4526),
  );

  /// Warm charcoal, not pure black.
  static const dark = AppPalette(
    background: Color(0xFF181411),
    surface: Color(0xFF241F1B),
    surfaceAlt: Color(0xFF302924),
    text: Color(0xFFF1E9DD),
    muted: Color(0xFFAA9E90),
    subtle: Color(0xFF7C7165),
    border: Color(0xFF3A322B),
    accent: Color(0xFFD98560),
    onAccent: Color(0xFF1E140F),
    accentDisabled: Color(0xFF6B4636),
    link: Color(0xFFE3A583),
  );

  @override
  AppPalette copyWith({
    Color? background,
    Color? surface,
    Color? surfaceAlt,
    Color? text,
    Color? muted,
    Color? subtle,
    Color? border,
    Color? accent,
    Color? onAccent,
    Color? accentDisabled,
    Color? link,
  }) =>
      AppPalette(
        background: background ?? this.background,
        surface: surface ?? this.surface,
        surfaceAlt: surfaceAlt ?? this.surfaceAlt,
        text: text ?? this.text,
        muted: muted ?? this.muted,
        subtle: subtle ?? this.subtle,
        border: border ?? this.border,
        accent: accent ?? this.accent,
        onAccent: onAccent ?? this.onAccent,
        accentDisabled: accentDisabled ?? this.accentDisabled,
        link: link ?? this.link,
      );

  @override
  AppPalette lerp(ThemeExtension<AppPalette>? other, double t) {
    if (other is! AppPalette) return this;
    return AppPalette(
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceAlt: Color.lerp(surfaceAlt, other.surfaceAlt, t)!,
      text: Color.lerp(text, other.text, t)!,
      muted: Color.lerp(muted, other.muted, t)!,
      subtle: Color.lerp(subtle, other.subtle, t)!,
      border: Color.lerp(border, other.border, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      onAccent: Color.lerp(onAccent, other.onAccent, t)!,
      accentDisabled: Color.lerp(accentDisabled, other.accentDisabled, t)!,
      link: Color.lerp(link, other.link, t)!,
    );
  }
}

extension AppPaletteContext on BuildContext {
  AppPalette get palette => Theme.of(this).extension<AppPalette>() ?? AppPalette.dark;
}
