// ─────────────────────────────────────────────────────────────────────────────
// File    : lib/domain/entities/saved_reel.dart
// Layer   : Domain (entity)
// Purpose : Result of persisting a picked video: the stored file name plus an
//           optional base64 JPEG thumbnail (null if generation failed).
// ─────────────────────────────────────────────────────────────────────────────

class SavedReel {
  const SavedReel({required this.fileName, this.thumbnailBase64});

  final String fileName;
  final String? thumbnailBase64;
}
