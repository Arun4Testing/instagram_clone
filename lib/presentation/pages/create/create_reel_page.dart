// ─────────────────────────────────────────────────────────────────────────────
// File    : lib/presentation/pages/create/create_reel_page.dart
// Layer   : Presentation (page)
// Purpose : "New reel" screen.
//           1. Pick a video from the gallery (max 90 s - checked by briefly
//              opening it in a VideoPlayerController to read its duration).
//           2. A JPEG thumbnail is generated and shown as the preview.
//           3. On Share, MediaRepository copies the file into app storage and
//              creates the final thumbnail, then a PostCreated event stores
//              the file name + thumbnail on the post.
// Dispatches : PostCreated (FeedBloc)
// ─────────────────────────────────────────────────────────────────────────────

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_palette.dart';
import '../../../domain/repositories/media_repository.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/feed/feed_bloc.dart';

enum PickSource { gallery, camera }

class CreateReelPage extends StatefulWidget {
  const CreateReelPage({super.key});

  @override
  State<CreateReelPage> createState() => _CreateReelPageState();
}

class _CreateReelPageState extends State<CreateReelPage> {
  final _caption = TextEditingController();
  XFile? _file;
  Uint8List? _previewBytes;
  bool _picking = false;
  bool _sharing = false;

  @override
  void dispose() {
    _caption.dispose();
    super.dispose();
  }

  void _toast(String message) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));

  Future<Duration> _durationOf(String path) async {
    final controller = VideoPlayerController.file(File(path));
    try {
      await controller.initialize();
      return controller.value.duration;
    } finally {
      await controller.dispose();
    }
  }
Future<void> _chooseSource() async {
  if (_picking || _sharing) return;
  final source = await showModalBottomSheet<PickSource>(
    context: context,
    builder: (sheetContext) => SafeArea(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        ListTile(
          leading: const Icon(Icons.photo_library_outlined),
          title: const Text('Gallery'),
          onTap: () => Navigator.pop(sheetContext, PickSource.gallery),
        ),
        ListTile(
          leading: const Icon(Icons.folder_open_outlined),
          title: const Text('Camera'),
          onTap: () => Navigator.pop(sheetContext, PickSource.camera),
        ),
      ]),
    ),
  );
  if (source != null) await _pickVideo(source);
}

Future<void> _pickVideo(PickSource source) async {
  final media = context.read<MediaRepository>();
  setState(() => _picking = true);
  try {
    final String? path;
    if (source == PickSource.gallery) {
      final picked = await ImagePicker().pickVideo(source: ImageSource.gallery);
      path = picked?.path;
    } else {
     final picked = await ImagePicker().pickVideo(source: ImageSource.camera);
      path = picked?.path;
    }
    if (path == null || !mounted) return;

    final duration = await _durationOf(path);
    if (!mounted) return;
    if (duration > AppConstants.maxReelDuration) {
      _toast('Please select a video of ${AppConstants.maxReelDuration.inSeconds} seconds or less.');
      return;
    }

    final thumbnail = await media.createThumbnail(path);
    if (!mounted) return;
    setState(() {
      _file = XFile(path!);
      _previewBytes = thumbnail == null ? null : base64Decode(thumbnail);
    });
  } catch (e) {
    if (mounted) _toast('Could not open that video: $e');
  } finally {
    if (mounted) setState(() => _picking = false);
  }
}

  Future<void> _share() async {
    final file = _file;
    final username = context.read<AuthBloc>().state.user?.username;
    if (file == null || username == null) return;

    final media = context.read<MediaRepository>();
    final feed = context.read<FeedBloc>();
    final caption = _caption.text.trim();
    setState(() => _sharing = true);
    try {
      final saved = await media.saveReel(file.path);
      feed.add(PostCreated(
        username: username,
        caption: caption,
        image: saved.thumbnailBase64,
        video: saved.fileName,
      ));
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        setState(() => _sharing = false);
        _toast('Could not share: $e');
      }
    }
  }

  Widget _preview() {
    if (_picking) return const Center(child: CircularProgressIndicator());
    if (_file == null) {
      return const Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(Icons.video_library_outlined, size: 56),
        SizedBox(height: 8),
        Text('Tap to choose a video (max 90 sec)'),
      ]);
    }
    return Stack(fit: StackFit.expand, children: [
      if (_previewBytes != null) Image.memory(_previewBytes!, fit: BoxFit.cover),
      const Center(child: Icon(Icons.play_circle_outline, size: 64, color: Colors.white70)),
    ]);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('New Yapps'),
          actions: [
            TextButton(
              onPressed: _file == null || _sharing ? null : _share,
              child: _sharing
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Share', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
        body: ListView(padding: const EdgeInsets.all(14), children: [
          GestureDetector(
            onTap: _chooseSource,
            child: AspectRatio(
              aspectRatio: 9 / 14,
              child: Container(
                decoration: BoxDecoration(color: context.palette.surfaceAlt, borderRadius: BorderRadius.circular(16)),
                clipBehavior: Clip.antiAlias,
                child: _preview(),
              ),
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _caption,
            maxLines: 3,
            decoration: const InputDecoration(hintText: 'Write a caption…', border: InputBorder.none),
          ),
        ]),
      );
}
