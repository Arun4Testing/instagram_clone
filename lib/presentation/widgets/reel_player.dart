// ─────────────────────────────────────────────────────────────────────────────
// File    : lib/presentation/widgets/reel_player.dart
// Layer   : Presentation (shared widget)
// Purpose : Plays ONE reel: autoplay, looping, with audio.
//
//   fullScreen = true  (reel viewer / Reels tab)  -> starts UNMUTED
//   fullScreen = false (inline in the home feed)  -> starts muted, tap the
//                                                   speaker to hear it
//
// Decoder budget: phones have only a few hardware video decoders, and large
// gallery videos (1080p60 / 4K) use more of them. So a controller exists ONLY
// while this player is the visible one ([_wantsDecoder]):
//   * isCurrent - the page is the one on screen in the PageView
//   * tab active - TickerMode is on (hidden IndexedStack tabs and routes
//                  covered by another route switch it off)
// Otherwise the controller is disposed and the thumbnail is shown.
//
// Playback (inside that window) also requires: app in foreground and not
// paused by the user (single tap toggles pause).
//
// Failures: initialisation is retried automatically (a decoder is often free
// a moment later). After [_maxAttempts] the player shows "Video unavailable";
// tapping it retries. The real exception is printed with debugPrint.
//
// Used by : PostMedia (feed), ReelsPager (viewer + tab)
// ─────────────────────────────────────────────────────────────────────────────

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:video_player/video_player.dart';
import '../../domain/entities/post.dart';
import '../../domain/repositories/media_repository.dart';
import 'double_tap_heart.dart';
import 'post_image.dart';

class ReelPlayer extends StatefulWidget {
  const ReelPlayer({
    super.key,
    required this.post,
    this.isCurrent = true,
    this.fullScreen = false,
    this.onDoubleTap,
  });

  final Post post;
  final bool isCurrent;
  final bool fullScreen;
  final VoidCallback? onDoubleTap;

  @override
  State<ReelPlayer> createState() => _ReelPlayerState();
}

class _ReelPlayerState extends State<ReelPlayer> with WidgetsBindingObserver {
  static const _maxAttempts = 3;

  VideoPlayerController? _controller;
  Timer? _retryTimer;
  late bool _muted = !widget.fullScreen;
  bool _tabActive = true;
  bool _appActive = true;
  bool _pausedByUser = false;
  bool _loading = false;
  bool _failed = false;
  int _attempt = 0;
  int _initToken = 0; // invalidates in-flight initialisations
  String _lastError = '';

  /// Should this player hold a video decoder right now?
  bool get _wantsDecoder => widget.isCurrent && _tabActive;

  bool get _shouldPlay => _appActive && !_pausedByUser;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // The first _sync() happens in didChangeDependencies (called right after).
  }

  /// Single place that reconciles the controller with the current conditions.
  void _sync() {
    if (!_wantsDecoder) {
      _release();
      return;
    }
    final c = _controller;
    if (c == null) {
      if (!_loading && !_failed) _initController();
      return;
    }
    if (!c.value.isInitialized) return;
    if (_shouldPlay) {
      if (!c.value.isPlaying) c.play();
    } else if (c.value.isPlaying) {
      c.pause();
    }
  }

  Future<void> _initController() async {
    final media = context.read<MediaRepository>();
    final token = ++_initToken;
    _loading = true;
    VideoPlayerController? controller;
    try {
      final file = await media.resolveVideo(widget.post.video!);
      if (file == null) throw StateError('Video file is missing');
      controller = VideoPlayerController.file(file);
      await controller.initialize();
      await controller.setLooping(true);
      await controller.setVolume(_muted ? 0 : 1);
      if (!mounted || token != _initToken) {
        await controller.dispose(); // became invisible while loading
        return;
      }
      _attempt = 0;
      _lastError = '';
      setState(() => _controller = controller);
      _sync();
    } catch (e) {
      await controller?.dispose();
      debugPrint('ReelPlayer init failed for ${widget.post.video} '
          '(attempt ${_attempt + 1}/$_maxAttempts): $e');
      if (!mounted || token != _initToken) return;
      _lastError = '$e';
      if (_attempt < _maxAttempts - 1) {
        _attempt++;
        _retryTimer?.cancel();
        _retryTimer = Timer(Duration(milliseconds: 400 * _attempt), () {
          if (mounted && _wantsDecoder && _controller == null) _initController();
        });
      } else {
        setState(() => _failed = true);
      }
    } finally {
      if (token == _initToken) _loading = false;
    }
  }

  /// Frees the decoder (used when hidden / off-screen / disposed).
  void _release() {
    _retryTimer?.cancel();
    _initToken++;
    _loading = false;
    final c = _controller;
    _controller = null;
    c?.dispose();
  }

  void _retry() {
    setState(() {
      _failed = false;
      _attempt = 0;
    });
    _sync();
  }

  // TickerMode is switched off for hidden tabs and for pages under another
  // route, so this is how a covered player knows to release its decoder.
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _tabActive = TickerMode.of(context);
    _sync();
  }

  @override
  void didUpdateWidget(ReelPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isCurrent != oldWidget.isCurrent) {
      if (widget.isCurrent) _pausedByUser = false; // a fresh controller starts at 0
      _sync();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _appActive = state == AppLifecycleState.resumed;
    _sync();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _release();
    super.dispose();
  }

  void _togglePause() {
    setState(() => _pausedByUser = !_pausedByUser);
    _sync();
  }

  void _toggleMute() {
    setState(() => _muted = !_muted);
    _controller?.setVolume(_muted ? 0 : 1);
  }

  @override
  Widget build(BuildContext context) {
    final c = _controller;
    return DoubleTapHeart(
      onTap: _failed ? _retry : _togglePause,
      onDoubleTap: widget.onDoubleTap,
      child: ColoredBox(
        color: Colors.black,
        child: Stack(fit: StackFit.expand, children: [
          if (c == null)
            PostImage(post: widget.post)
          else
            FittedBox(
              fit: BoxFit.cover,
              clipBehavior: Clip.hardEdge,
              child: SizedBox(
                width: c.value.size.width,
                height: c.value.size.height,
                child: VideoPlayer(c),
              ),
            ),
          if (_failed)
            Center(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.white70),
                const SizedBox(height: 8),
                const Text('Video unavailable', style: TextStyle(color: Colors.white70)),
                const SizedBox(height: 4),
                const Text('Tap to retry', style: TextStyle(color: Colors.white38, fontSize: 12)),
                if (kDebugMode && _lastError.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
                    child: Text(
                      _lastError,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white24, fontSize: 10),
                    ),
                  ),
              ]),
            )
          else if (c == null && _wantsDecoder)
            const Center(
              child: SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white70),
              ),
            )
          else if (_pausedByUser && c != null)
            const Center(child: Icon(Icons.play_arrow_rounded, size: 80, color: Colors.white70)),
          if (!widget.fullScreen)
            const Positioned(
              top: 10,
              right: 10,
              child: Icon(Icons.smart_display, color: Colors.white, shadows: [Shadow(blurRadius: 6)]),
            ),
          if (c != null)
            Positioned(
              top: widget.fullScreen ? MediaQuery.of(context).padding.top + 8 : null,
              bottom: widget.fullScreen ? null : 10,
              right: 10,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: _toggleMute,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                  child: Icon(
                    _muted ? Icons.volume_off : Icons.volume_up,
                    size: 20,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
        ]),
      ),
    );
  }
}