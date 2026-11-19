// ─────────────────────────────────────────────────────────────────────────────
// File    : lib/domain/repositories/media_repository.dart
// Layer   : Domain (contract)
// Purpose : Access to video files and thumbnails, hiding path_provider and the
//           thumbnail plugin from the rest of the app.
// Impl    : data/repositories/media_repository_impl.dart
// ─────────────────────────────────────────────────────────────────────────────

import 'dart:io';
import '../entities/saved_reel.dart';

abstract class MediaRepository {
  /// Resolves a stored reel file name to a [File], or null if it is missing.
  Future<File?> resolveVideo(String fileName);

  /// Copies a picked video into app storage and generates its thumbnail.
  Future<SavedReel> saveReel(String sourcePath);

  /// Returns a base64 JPEG of an early frame, or null if it cannot be made.
  Future<String?> createThumbnail(String videoPath);
}
