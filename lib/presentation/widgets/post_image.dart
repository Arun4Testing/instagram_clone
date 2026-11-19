// ─────────────────────────────────────────────────────────────────────────────
// File    : lib/presentation/widgets/post_image.dart
// Layer   : Presentation (shared widget)
// Purpose : Static picture for a post. Uses the stored base64 image (photo or
//           reel thumbnail) and falls back to a gradient. It NEVER opens a
//           video decoder - that is what keeps grids light and lets the one
//           real player in the reel viewer always get a decoder.
//           The base64 string is decoded once (not on every rebuild) to avoid
//           flicker when a like/comment rebuilds the parent.
// Used by : PostTile, PostMedia, ReelPlayer (while loading)
// ─────────────────────────────────────────────────────────────────────────────

import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../domain/entities/post.dart';

class PostImage extends StatefulWidget {
  const PostImage({super.key, required this.post});

  final Post post;

  @override
  State<PostImage> createState() => _PostImageState();
}

class _PostImageState extends State<PostImage> {
  Uint8List? _bytes;

  @override
  void initState() {
    super.initState();
    _decode();
  }

  @override
  void didUpdateWidget(PostImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.post.image != widget.post.image) _decode();
  }

  void _decode() {
    final encoded = widget.post.image;
    try {
      _bytes = encoded == null ? null : base64Decode(encoded);
    } catch (_) {
      _bytes = null; // corrupt data -> show the gradient instead of crashing
    }
  }

  @override
  Widget build(BuildContext context) {
    final bytes = _bytes;
    if (bytes != null) {
      return Image.memory(
        bytes,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        gaplessPlayback: true,
      );
    }
    final colors = AppColors.gradients[widget.post.seed % AppColors.gradients.length];
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: colors, begin: Alignment.topLeft, end: Alignment.bottomRight),
      ),
      child: widget.post.isReel
          ? const Center(child: Icon(Icons.play_circle_outline, size: 40, color: Colors.white70))
          : null,
    );
  }
}
