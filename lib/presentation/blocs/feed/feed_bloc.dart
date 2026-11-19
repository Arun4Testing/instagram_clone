// ─────────────────────────────────────────────────────────────────────────────
// File    : lib/presentation/blocs/feed/feed_bloc.dart
// Layer   : Presentation (bloc)
// Purpose : Loads posts and handles likes, comments and new posts.
//           Talks only to the [PostRepository] interface from the domain layer.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/post.dart';
import '../../../domain/repositories/post_repository.dart';

part 'feed_event.dart';
part 'feed_state.dart';

class FeedBloc extends Bloc<FeedEvent, FeedState> {
  FeedBloc(this._repository) : super(const FeedState(isLoading: true)) {
    on<FeedStarted>(_onStarted);
    on<LikeToggled>(_onLikeToggled);
    on<CommentAdded>(_onCommentAdded);
    on<PostCreated>(_onPostCreated);
  }

  final PostRepository _repository;

  Future<void> _onStarted(FeedStarted event, Emitter<FeedState> emit) async {
    emit(FeedState(posts: await _repository.getPosts()));
  }

  Future<void> _onLikeToggled(LikeToggled event, Emitter<FeedState> emit) async {
    final posts = await _repository.toggleLike(postId: event.postId, username: event.username);
    emit(FeedState(posts: posts));
  }

  Future<void> _onCommentAdded(CommentAdded event, Emitter<FeedState> emit) async {
    final posts = await _repository.addComment(
      postId: event.postId,
      username: event.username,
      text: event.text,
    );
    emit(FeedState(posts: posts));
  }

  Future<void> _onPostCreated(PostCreated event, Emitter<FeedState> emit) async {
    final posts = await _repository.createPost(
      username: event.username,
      caption: event.caption,
      image: event.image,
      video: event.video,
    );
    emit(FeedState(posts: posts));
  }
}
