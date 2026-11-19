// ─────────────────────────────────────────────────────────────────────────────
// File    : lib/presentation/navigation/open_post.dart
// Layer   : Presentation (navigation helper)
// Purpose : One place that decides what tapping a grid tile does:
//             reel  -> full-screen ReelsViewerPage (autoplay with sound)
//             photo -> comments sheet
// Used by : ExploreTab, ProfileTab
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import '../../domain/entities/post.dart';
import '../pages/comments/comments_sheet.dart';
import '../pages/reels/reels_viewer_page.dart';

void openPost(BuildContext context, Post post, {String? onlyUser}) {
  FocusScope.of(context).unfocus(); // close the search keyboard first
  if (post.isReel) {
    Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (_) => ReelsViewerPage(startPostId: post.id, onlyUser: onlyUser),
    ));
  } else {
    showCommentsSheet(context, post.id);
  }
}
