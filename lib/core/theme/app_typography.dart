// ─────────────────────────────────────────────────────────────────────────────
// File    : lib/core/theme/app_typography.dart
// Layer   : Core
// Purpose : The editorial serif used for headings, usernames and captions.
//           Uses system serif fonts (Georgia on iOS, Noto Serif on Android)
//           so no extra package or asset is needed.
//           To use a bundled / Google font instead (e.g. Fraunces, Playfair
//           Display), change ONLY this file.
// Used by : AppTheme and presentation widgets
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';

class AppTypography {
  AppTypography._();

  static const String serifFamily = 'Georgia';
  static const List<String> serifFallback = ['Times New Roman', 'Noto Serif', 'serif'];

  static TextStyle serif({
    double? fontSize,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    double? letterSpacing,
    double? height,
    Color? color,
  }) =>
      TextStyle(
        fontFamily: serifFamily,
        fontFamilyFallback: serifFallback,
        fontSize: fontSize,
        fontWeight: fontWeight,
        fontStyle: fontStyle,
        letterSpacing: letterSpacing,
        height: height,
        color: color,
      );
}
