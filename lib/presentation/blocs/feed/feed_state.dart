// ─────────────────────────────────────────────────────────────────────────────
// File    : lib/presentation/blocs/feed/feed_state.dart
// Layer   : Presentation (bloc state)
// Purpose : The list of posts plus a loading flag for the first load.
// ─────────────────────────────────────────────────────────────────────────────

part of 'feed_bloc.dart';

class FeedState extends Equatable {
  const FeedState({this.posts = const [], this.isLoading = false});

  final List<Post> posts;
  final bool isLoading;

  @override
  List<Object?> get props => [posts, isLoading];
}
