// ─────────────────────────────────────────────────────────────────────────────
// File    : lib/presentation/pages/splash/splash_page.dart
// Layer   : Presentation (page)
// Purpose : Launch screen: the Folio mark and name centred, tagline at the foot.
// Shown by: AuthGate for AppConstants.splashDuration
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/app_typography.dart';
import '../../widgets/picyammer_mark.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Scaffold(
      body: Stack(children: [
        Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const PicYapper(84),
            const SizedBox(height: 18),
            Text(
              AppConstants.appName,
              style: AppTypography.serif(fontSize: 38, fontWeight: FontWeight.w600, fontStyle: FontStyle.italic),
            ),
          ]),
        ),
        Positioned(
          bottom: 48,
          left: 0,
          right: 0,
          child: Text(
            AppConstants.tagline,
            textAlign: TextAlign.center,
            style: AppTypography.serif(fontSize: 16, fontStyle: FontStyle.italic, color: p.muted),
          ),
        ),
      ]),
    );
  }
}
