// ─────────────────────────────────────────────────────────────────────────────
// File    : lib/presentation/pages/splash/splash_page.dart
// Layer   : Presentation (page)
// Purpose : Launch screen: centred logo with the "from Meta" footer.
// Shown by: AuthGate for AppConstants.splashDuration
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../widgets/ig_logo.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: AppColors.splashBackground,
        body: Stack(children: [
          const Center(child: IgLogo(84)),
          Positioned(
            bottom: 48,
            left: 0,
            right: 0,
            child: Column(children: [
              Text('from', style: TextStyle(color: Colors.blueGrey.shade300, fontSize: 18)),
              const SizedBox(height: 4),
              ShaderMask(
                shaderCallback: (rect) => const LinearGradient(
                  colors: [Color(0xFFFF7A00), Color(0xFFFF0069)],
                ).createShader(rect),
                child: const Text(
                  '∞ Meta',
                  style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w600),
                ),
              ),
            ]),
          ),
        ]),
      );
}
