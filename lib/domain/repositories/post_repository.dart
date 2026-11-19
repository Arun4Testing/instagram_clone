// ─────────────────────────────────────────────────────────────────────────────
// File    : lib/domain/repositories/post_repository.dart
// Layer   : Domain (contract)
// Purpose : Feed operations. Every mutating call returns the full, updated
//           list so the Bloc can emit it directly.
// Impl    : data/repositories/post_repository_impl.dart
// ─────────────────────────────────────────────────────────────────────────────

import '../entities/post.dart';

abstract class PostRepository {
  Future<List<Post>> getPosts();

  Future<List<Post>> toggleLike({required int postId, required String username});

  Future<List<Post>> addComment({
    required int postId,
    required String username,
    required String text,
  });

  Future<List<Post>> createPost({
    required String username,
    required String caption,
    String? image,
    String? video,
  });
}
