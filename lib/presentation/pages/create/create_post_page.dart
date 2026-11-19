// ─────────────────────────────────────────────────────────────────────────────
// File    : lib/presentation/pages/create/create_post_page.dart
// Layer   : Presentation (page)
// Purpose : "New post" screen: choose a photo from the gallery, write a
//           caption and share. The photo is downscaled (900px, 70% quality)
//           and stored as base64 on the post.
// Dispatches : PostCreated (FeedBloc)
// ─────────────────────────────────────────────────────────────────────────────

import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/theme/app_palette.dart';
import 'create_reel_page.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/feed/feed_bloc.dart';

class CreatePostPage extends StatefulWidget {
  const CreatePostPage({super.key});

  @override
  State<CreatePostPage> createState() => _CreatePostPageState();
}

class _CreatePostPageState extends State<CreatePostPage> {
  final _caption = TextEditingController();
  Uint8List? _bytes;

  @override
  void dispose() {
    _caption.dispose();
    super.dispose();
  }

  Future<void> _chooseSource() async {
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
    if (source != null) await _pickImage(source);
  }

  Future<void> _pickImage(PickSource source) async {
    Uint8List? bytes;
    if (source == PickSource.gallery) {
      final file = await ImagePicker().pickImage(
          source: ImageSource.gallery, maxWidth: 900, imageQuality: 70);
      if (file == null) return;
      bytes = await file.readAsBytes();
    } else {
         final file = await ImagePicker().pickImage(
          source: ImageSource.camera, maxWidth: 900, imageQuality: 70);
      if (file == null) return;
      bytes = await file.readAsBytes();
      // final file = await FilePicker.pickFile(type: FileType.image);
      // if (file == null) return;
      // bytes = await file.readAsBytes();
    }
    if (!mounted) return;
    setState(() => _bytes = bytes);
  }

  void _share() {
    final bytes = _bytes;
    final username = context.read<AuthBloc>().state.user?.username;
    if (bytes == null || username == null) return;
    context.read<FeedBloc>().add(PostCreated(
          username: username,
          caption: _caption.text.trim(),
          image: base64Encode(bytes),
        ));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('New post'),
          actions: [
            TextButton(
              onPressed: _bytes == null ? null : _share,
              child: const Text('Share', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
        body: ListView(padding: const EdgeInsets.all(14), children: [
          GestureDetector(
            onTap: _chooseSource,
            child: AspectRatio(
              aspectRatio: 1,
              child: Container(
                decoration: BoxDecoration(
                    color: context.palette.surfaceAlt,
                    borderRadius: BorderRadius.circular(16)),
                clipBehavior: Clip.antiAlias,
                child: _bytes == null
                    ? const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                            Icon(Icons.add_photo_alternate_outlined, size: 56),
                            SizedBox(height: 8),
                            Text('Tap to choose a photo'),
                          ])
                    : Image.memory(_bytes!, fit: BoxFit.cover),
              ),
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _caption,
            maxLines: 3,
            decoration: const InputDecoration(
                hintText: 'Write a caption…', border: InputBorder.none),
          ),
        ]),
      );
}
