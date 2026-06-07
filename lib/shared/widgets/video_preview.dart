import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../../core/theme/app_theme.dart';

/// A muted, auto-playing, looping video used as a gallery card thumbnail.
///
/// The video is cover-fitted into its parent (which must impose bounded
/// constraints — the card preview box does). Audio is disabled so it can
/// autoplay on the web without a user gesture.
class VideoPreview extends StatefulWidget {
  final String asset;

  /// Background shown behind the video before it finishes initialising.
  final Color background;

  const VideoPreview({
    super.key,
    required this.asset,
    this.background = AppTheme.surfaceVariant,
  });

  @override
  State<VideoPreview> createState() => _VideoPreviewState();
}

class _VideoPreviewState extends State<VideoPreview> {
  late final VideoPlayerController _controller;
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset(widget.asset)
      ..setLooping(true)
      ..setVolume(0); // muted → allowed to autoplay on web
    _controller.initialize().then((_) {
      if (!mounted) return;
      _controller.play();
      setState(() => _ready = true);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_ready) {
      return ColoredBox(color: widget.background, child: const SizedBox.expand());
    }
    return ColoredBox(
      color: widget.background,
      child: FittedBox(
        fit: BoxFit.cover,
        clipBehavior: Clip.hardEdge,
        child: SizedBox(
          width: _controller.value.size.width,
          height: _controller.value.size.height,
          child: VideoPlayer(_controller),
        ),
      ),
    );
  }
}
