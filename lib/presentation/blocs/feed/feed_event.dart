// ─────────────────────────────────────────────────────────────────────────────
// File    : lib/presentation/blocs/feed/feed_event.dart
// Layer   : Presentation (bloc events)
// Purpose : Everything the UI can ask the FeedBloc to do. The acting username
//           travels inside the event so the bloc stays independent of auth.
// ─────────────────────────────────────────────────────────────────────────────

part of 'feed_bloc.dart';

abstract class FeedEvent {
  const FeedEvent();
}

class FeedStarted extends FeedEvent {
  const FeedStarted();
}

class LikeToggled extends FeedEvent {
  const LikeToggled({required this.postId, required this.username});
  final int postId;
  final String username;
}

class CommentAdded extends FeedEvent {
  const CommentAdded({required this.postId, required this.username, required this.text});
  final int postId;
  final String username;
  final String text;
}

/// A photo post sets [image]; a reel sets [video] (file name) and [image]
/// (its thumbnail).
class PostCreated extends FeedEvent {
  const PostCreated({required this.username, required this.caption, this.image, this.video});
  final String username;
  final String caption;
  final String? image;
  final String? video;
}
