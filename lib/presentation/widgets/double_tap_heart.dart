// ─────────────────────────────────────────────────────────────────────────────
// File    : lib/presentation/widgets/double_tap_heart.dart
// Layer   : Presentation (shared widget)
// Purpose : Wraps any child with ONE gesture handler for single tap and double
//           tap, and plays the white "heart pop" animation on double tap.
//           Using a single detector (instead of nested ones) avoids the inner
//           handler swallowing the outer one's double-tap.
//           behavior=opaque so taps register even over a video texture.
// Used by : PostMedia, ReelPlayer
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';

class DoubleTapHeart extends StatefulWidget {
  const DoubleTapHeart({super.key, required this.child, this.onDoubleTap, this.onTap});

  final Widget child;
  final VoidCallback? onDoubleTap;
  final VoidCallback? onTap;

  @override
  State<DoubleTapHeart> createState() => _DoubleTapHeartState();
}

class _DoubleTapHeartState extends State<DoubleTapHeart> with SingleTickerProviderStateMixin {
  late final AnimationController _controller =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 650));

  late final Animation<double> _scale = TweenSequence<double>([
    TweenSequenceItem(
      tween: Tween(begin: 0.3, end: 1.18).chain(CurveTween(curve: Curves.easeOutBack)),
      weight: 45,
    ),
    TweenSequenceItem(
      tween: Tween(begin: 1.18, end: 1.0).chain(CurveTween(curve: Curves.easeInOut)),
      weight: 20,
    ),
    TweenSequenceItem(tween: ConstantTween(1.0), weight: 35),
  ]).animate(_controller);

  late final Animation<double> _opacity = TweenSequence<double>([
    TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 20),
    TweenSequenceItem(tween: ConstantTween(1.0), weight: 45),
    TweenSequenceItem(
      tween: Tween(begin: 1.0, end: 0.0).chain(CurveTween(curve: Curves.easeOut)),
      weight: 35,
    ),
  ]).animate(_controller);

  bool _showHeart = false;

  void _onDoubleTap() {
    widget.onDoubleTap?.call();
    setState(() => _showHeart = true);
    _controller.forward(from: 0).then((_) {
      if (mounted) setState(() => _showHeart = false);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTap,
        onDoubleTap: _onDoubleTap,
        child: Stack(fit: StackFit.expand, children: [
          widget.child,
          if (_showHeart)
            IgnorePointer(
              child: Center(
                child: FadeTransition(
                  opacity: _opacity,
                  child: ScaleTransition(
                    scale: _scale,
                    child: const Icon(
                      Icons.favorite,
                      size: 104,
                      color: Colors.white,
                      shadows: [Shadow(blurRadius: 24, color: Colors.black54)],
                    ),
                  ),
                ),
              ),
            ),
        ]),
      );
}
