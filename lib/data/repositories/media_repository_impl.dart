// ─────────────────────────────────────────────────────────────────────────────
// File    : lib/data/repositories/media_repository_impl.dart
// Layer   : Data (repository implementation)
// Purpose : Stores reel videos in the app documents folder and produces JPEG
//           thumbnails with the `video_thumbnail` plugin.
//           Only the FILE NAME is saved in a Post (absolute paths change
//           between app launches/updates on iOS).
// ─────────────────────────────────────────────────────────────────────────────

import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:fc_native_video_thumbnail/fc_native_video_thumbnail.dart';
import '../../domain/entities/saved_reel.dart';
import '../../domain/repositories/media_repository.dart';

class MediaRepositoryImpl implements MediaRepository {
  Directory? _docs;

  Future<Directory> _documentsDir() async =>
      _docs ??= await getApplicationDocumentsDirectory();

  @override
  Future<File?> resolveVideo(String fileName) async {
    final file = File('${(await _documentsDir()).path}/$fileName');
    return await file.exists() ? file : null;
  }

  @override
  Future<SavedReel> saveReel(String sourcePath) async {
    final dir = await _documentsDir();
    final name = 'reel_${DateTime.now().millisecondsSinceEpoch}${_extensionOf(sourcePath)}';
    final saved = await File(sourcePath).copy('${dir.path}/$name');
    final thumbnail = await createThumbnail(saved.path);
    return SavedReel(fileName: name, thumbnailBase64: thumbnail);
  }
  @override
  Future<String?> createThumbnail(String videoPath) async {
    try {
      final bytes = await FcNativeVideoThumbnail().saveThumbnailToBytes(
        srcFile: videoPath,
        width: 480,
        height: 480,
        quality: 70,
      );
      if (bytes == null || bytes.isEmpty) return null;
      return base64Encode(bytes);
    } catch (_) {
      return null;
    }
  }

  /// Keeps the picked file's extension (.mp4, .mov, ...) so the platform
  /// decoder can recognise the container. Falls back to .mp4.
  String _extensionOf(String path) {
    final dot = path.lastIndexOf('.');
    final slash = path.lastIndexOf('/');
    if (dot <= slash || path.length - dot > 6) return '.mp4';
    return path.substring(dot).toLowerCase();
  }
}
