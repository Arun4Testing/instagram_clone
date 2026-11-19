// ─────────────────────────────────────────────────────────────────────────────
// File    : lib/presentation/pages/comments/comments_sheet.dart
// Layer   : Presentation (page / bottom sheet)
// Purpose : Modal bottom sheet listing a post's comments with an emoji row and
//           a text field to add a new one. Reads live data from FeedBloc.
// Opened  : showCommentsSheet(context, postId) from feed, reels, explore
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/time_ago.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/feed/feed_bloc.dart';
import '../../widgets/avatar.dart';

void showCommentsSheet(BuildContext context, int postId) {
  final me = context.read<AuthBloc>().state.user?.username ?? '';
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.sheet,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
    builder: (_) => SafeArea(child: _CommentsSheet(postId: postId, me: me)),
  );
}

class _CommentsSheet extends StatefulWidget {
  const _CommentsSheet({required this.postId, required this.me});

  final int postId;
  final String me;

  @override
  State<_CommentsSheet> createState() => _CommentsSheetState();
}

class _CommentsSheetState extends State<_CommentsSheet> {
  static const _emojis = ['❤️', '🙌', '🔥', '👏', '😢', '😍', '😮', '😂'];
  final _input = TextEditingController();

  @override
  void dispose() {
    _input.dispose();
    super.dispose();
  }

  void _send(int postId) {
    final text = _input.text.trim();
    if (text.isEmpty) return;
    context.read<FeedBloc>().add(CommentAdded(postId: postId, username: widget.me, text: text));
    _input.clear();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SizedBox(
        height: height * .72,
        child: BlocBuilder<FeedBloc, FeedState>(builder: (context, state) {
          final matches = state.posts.where((p) => p.id == widget.postId);
          if (matches.isEmpty) return const SizedBox.shrink();
          final post = matches.first;
          final hasText = _input.text.trim().isNotEmpty;

          return Column(children: [
            const SizedBox(height: 10),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(color: Colors.white38, borderRadius: BorderRadius.circular(4)),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Text('Comments', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
            ),
            const Divider(height: 1, color: Colors.white12),
            Expanded(
              child: post.comments.isEmpty
                  ? const Center(
                      child: Text(
                        'No comments yet.\nStart the conversation.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white54),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(14),
                      itemCount: post.comments.length,
                      itemBuilder: (_, k) {
                        final comment = post.comments[post.comments.length - 1 - k];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 18),
                          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Avatar(comment.user, size: 40),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                Text.rich(TextSpan(children: [
                                  TextSpan(text: comment.user, style: const TextStyle(fontWeight: FontWeight.w700)),
                                  TextSpan(
                                    text: '  ${shortAgo(comment.timestamp)}',
                                    style: const TextStyle(color: Colors.white54),
                                  ),
                                ])),
                                const SizedBox(height: 2),
                                Text(comment.text, style: const TextStyle(fontSize: 16)),
                                const SizedBox(height: 4),
                                const Text(
                                  'Reply',
                                  style: TextStyle(color: Colors.white54, fontWeight: FontWeight.w600),
                                ),
                              ]),
                            ),
                            const Icon(Icons.favorite_border, size: 22, color: Colors.white70),
                          ]),
                        );
                      },
                    ),
            ),
            SizedBox(
              height: 50,
              child: ListView(scrollDirection: Axis.horizontal, children: [
                for (final emoji in _emojis)
                  InkWell(
                    onTap: () {
                      _input.text += emoji;
                      setState(() {});
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      child: Center(child: Text(emoji, style: const TextStyle(fontSize: 26))),
                    ),
                  ),
              ]),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 14),
              child: Row(children: [
                Avatar(widget.me, size: 40),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _input,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      hintText: 'Join the conversation…',
                      hintStyle: const TextStyle(color: Colors.white54),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                      suffixIcon: Padding(
                        padding: const EdgeInsets.all(5),
                        child: GestureDetector(
                          onTap: () => _send(post.id),
                          child: Container(
                            width: 60,
                            decoration: BoxDecoration(
                              color: hasText ? AppColors.accent : AppColors.accentDisabled,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Icon(Icons.arrow_upward, size: 26),
                          ),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: const BorderSide(color: Colors.white24),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: const BorderSide(color: Colors.white38),
                      ),
                    ),
                  ),
                ),
              ]),
            ),
          ]);
        }),
      ),
    );
  }
}
