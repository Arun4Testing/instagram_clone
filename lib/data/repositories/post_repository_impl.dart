// ─────────────────────────────────────────────────────────────────────────────
// File    : lib/data/repositories/post_repository_impl.dart
// Layer   : Data (repository implementation)
// Purpose : Feed persistence. Keeps posts cached in memory and writes every
//           change through [LocalStorage].
//           On first load it also back-fills thumbnails for reels that were
//           created before thumbnails existed (so old reels render too).
// ─────────────────────────────────────────────────────────────────────────────

import '../../domain/entities/comment.dart';
import '../../domain/entities/post.dart';
import '../../domain/repositories/media_repository.dart';
import '../../domain/repositories/post_repository.dart';
import '../datasources/local_storage.dart';
import '../datasources/seed_data.dart';

class PostRepositoryImpl implements PostRepository {
  PostRepositoryImpl(this._storage, this._media);

  final LocalStorage _storage;
  final MediaRepository _media;
  List<Post>? _cache;

  @override
  Future<List<Post>> getPosts() async {
    final cached = _cache;
    if (cached != null) return cached;

    final stored = _storage.readPosts();
    final loaded = stored ?? buildSeedPosts();
    final result = await _backfillReelThumbnails(loaded);

    _cache = result.posts;
    if (stored == null || result.changed) await _storage.writePosts(result.posts);
    return result.posts;
  }

  @override
  Future<List<Post>> toggleLike({required int postId, required String username}) async {
    final updated = (await getPosts()).map((p) {
      if (p.id != postId) return p;
      final likes = List<String>.from(p.likes);
      if (likes.contains(username)) {
        likes.remove(username);
      } else {
        likes.add(username);
      }
      return p.copyWith(likes: likes);
    }).toList();
    return _persist(updated);
  }

  @override
  Future<List<Post>> addComment({
    required int postId,
    required String username,
    required String text,
  }) async {
    final comment = Comment(
      user: username,
      text: text,
      timestamp: DateTime.now().millisecondsSinceEpoch,
    );
    final updated = (await getPosts())
        .map((p) => p.id != postId ? p : p.copyWith(comments: [...p.comments, comment]))
        .toList();
    return _persist(updated);
  }

  @override
  Future<List<Post>> createPost({
    required String username,
    required String caption,
    String? image,
    String? video,
  }) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final post = Post(
      id: now,
      user: username,
      caption: caption,
      image: image,
      video: video,
      timestamp: now,
    );
    return _persist([post, ...await getPosts()]);
  }

  Future<List<Post>> _persist(List<Post> posts) async {
    _cache = posts;
    await _storage.writePosts(posts);
    return posts;
  }

  Future<({List<Post> posts, bool changed})> _backfillReelThumbnails(List<Post> posts) async {
    var changed = false;
    final out = <Post>[];
    for (final p in posts) {
      if (p.isReel && p.image == null) {
        final file = await _media.resolveVideo(p.video!);
        final thumb = file == null ? null : await _media.createThumbnail(file.path);
        if (thumb != null) {
          out.add(p.copyWith(image: thumb));
          changed = true;
          continue;
        }
      }
      out.add(p);
    }
    return (posts: out, changed: changed);
  }
}
