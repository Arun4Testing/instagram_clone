// ─────────────────────────────────────────────────────────────────────────────
// File    : lib/presentation/widgets/ig_logo.dart
// Layer   : Presentation (shared widget)
// Purpose : Gradient camera-style logo drawn with plain containers (no asset).
// Used by : SplashPage, LoginPage
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';

class IgLogo extends StatelessWidget {
  const IgLogo(this.size, {super.key});

  final double size;

  @override
  Widget build(BuildContext context) => ShaderMask(
        shaderCallback: (rect) => const LinearGradient(
          begin: Alignment.bottomLeft,
          end: Alignment.topRight,
          colors: [Color(0xFFFFD600), Color(0xFFFF0069), Color(0xFFD300C5), Color(0xFF7638FA)],
        ).createShader(rect),
        child: SizedBox(
          width: size,
          height: size,
          child: Stack(children: [
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: size * .09),
                borderRadius: BorderRadius.circular(size * .3),
              ),
            ),
            Center(
              child: Container(
                width: size * .5,
                height: size * .5,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: size * .09),
                ),
              ),
            ),
            Positioned(
              top: size * .2,
              right: size * .2,
              child: Container(
                width: size * .1,
                height: size * .1,
                decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
              ),
            ),
          ]),
        ),
      );
}
