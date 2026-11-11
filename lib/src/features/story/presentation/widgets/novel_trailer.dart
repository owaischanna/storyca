import 'dart:async';

import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';
import 'package:storryca/src/core/constants/colors.const.dart';
import 'package:storryca/src/core/network/models/story_api_model.dart';
import 'package:storryca/src/core/widgets/app_image.dart';
import 'package:video_player/video_player.dart';

/// The novel trailer on the details page. Nothing is downloaded until the
/// reader taps play — readers pay for their own data — so until then it shows
/// the novel's cover as the poster (as the website does), with a play button,
/// the running time and a label.
class NovelTrailer extends StatefulWidget {
  const NovelTrailer({super.key, required this.trailer, this.posterUrl});

  final StoryTrailer trailer;

  /// The novel's cover, already loaded on this page, so it costs no data.
  final String? posterUrl;

  @override
  State<NovelTrailer> createState() => _NovelTrailerState();
}

class _NovelTrailerState extends State<NovelTrailer> {
  VideoPlayerController? _controller;
  bool _loading = false;
  bool _failed = false;

  /// Controls show on tap and fade after a few seconds of playing.
  bool _showControls = true;
  Timer? _hideTimer;

  @override
  void dispose() {
    _hideTimer?.cancel();
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _start() async {
    if (_loading) return;
    setState(() {
      _loading = true;
      _failed = false;
    });
    final controller = VideoPlayerController.networkUrl(
      Uri.parse(widget.trailer.url),
    );
    try {
      await controller.initialize();
      if (!mounted) {
        await controller.dispose();
        return;
      }
      controller.addListener(_onTick);
      setState(() {
        _controller = controller;
        _loading = false;
      });
      await controller.play();
      _scheduleHide();
    } catch (_) {
      await controller.dispose();
      if (!mounted) return;
      setState(() {
        _loading = false;
        _failed = true;
      });
    }
  }

  void _onTick() {
    if (mounted) setState(() {});
  }

  void _scheduleHide() {
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(seconds: 3), () {
      if (mounted && (_controller?.value.isPlaying ?? false)) {
        setState(() => _showControls = false);
      }
    });
  }

  void _togglePlay() {
    final controller = _controller;
    if (controller == null) return;
    final value = controller.value;
    if (value.isPlaying) {
      controller.pause();
      _hideTimer?.cancel();
      setState(() => _showControls = true);
    } else {
      if (value.position >= value.duration) controller.seekTo(Duration.zero);
      controller.play();
      _scheduleHide();
    }
  }

  void _onSurfaceTap() {
    setState(() => _showControls = !_showControls);
    if (_showControls) _scheduleHide();
  }

  String _time(Duration d) {
    final minutes = d.inMinutes;
    final seconds = d.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black,
          border: Border.all(
            width: 1,
            color: Color.fromRGBO(181, 77, 232, 0.3),
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(7),
          child: AspectRatio(
            aspectRatio: widget.trailer.aspectRatio,
            child: controller == null ? _poster() : _player(controller),
          ),
        ),
      ),
    );
  }

  Widget _label() => Positioned(
    top: 8,
    left: 8,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: Color.fromRGBO(0, 0, 0, 0.5),
        border: Border.all(
          width: 0.5,
          color: Color.fromRGBO(181, 77, 232, 0.5),
        ),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        'NOVEL TRAILER',
        style: TextStyle(
          color: Color(secondaryCOLR),
          fontSize: 9,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.8,
        ),
      ),
    ),
  );

  Widget _roundButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: defaultGradientTTB,
          boxShadow: [
            BoxShadow(color: Color.fromRGBO(145, 16, 222, 0.4), blurRadius: 16),
          ],
        ),
        child: Icon(icon, color: Colors.white, size: 30),
      ),
    );
  }

  Widget _poster() {
    return Stack(
      fit: StackFit.expand,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF1A0629), Color(0xFF05010A)],
            ),
          ),
        ),
        // Fitted whole inside the box, like the website's poster.
        if (widget.posterUrl != null)
          ColoredBox(
            color: Colors.black,
            child: AppImage(widget.posterUrl!, fit: BoxFit.contain),
          ),
        ColoredBox(color: Color.fromRGBO(0, 0, 0, 0.25)),
        Center(
          child: _loading
              ? SizedBox(
                  width: 36,
                  height: 36,
                  child: CircularProgressIndicator(
                    color: Color(secondaryCOLR),
                    strokeWidth: 3,
                  ),
                )
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  spacing: 8,
                  children: [
                    _roundButton(Remix.play_fill, _start),
                    if (_failed)
                      Text(
                        'Could not play the trailer. Tap to try again.',
                        style: TextStyle(color: Colors.white70, fontSize: 10),
                      ),
                  ],
                ),
        ),
        _label(),
        if (widget.trailer.durationLabel.isNotEmpty)
          Positioned(
            right: 8,
            bottom: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
              decoration: BoxDecoration(
                color: Color.fromRGBO(0, 0, 0, 0.6),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                widget.trailer.durationLabel,
                style: TextStyle(color: Colors.white, fontSize: 10),
              ),
            ),
          ),
      ],
    );
  }

  Widget _player(VideoPlayerController controller) {
    final value = controller.value;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _onSurfaceTap,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Fitted inside the box, never cropped or stretched.
          Center(
            child: AspectRatio(
              aspectRatio: value.aspectRatio,
              child: VideoPlayer(controller),
            ),
          ),
          AnimatedOpacity(
            opacity: _showControls ? 1 : 0,
            duration: const Duration(milliseconds: 200),
            child: IgnorePointer(
              ignoring: !_showControls,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ColoredBox(color: Color.fromRGBO(0, 0, 0, 0.3)),
                  Center(
                    child: value.isBuffering && value.isPlaying
                        ? CircularProgressIndicator(color: Color(secondaryCOLR))
                        : _roundButton(
                            value.isPlaying ? Remix.pause_fill : Remix.play_fill,
                            _togglePlay,
                          ),
                  ),
                  _label(),
                  Positioned(
                    left: 8,
                    right: 8,
                    bottom: 6,
                    child: Row(
                      spacing: 8,
                      children: [
                        Text(
                          _time(value.position),
                          style: TextStyle(color: Colors.white, fontSize: 10),
                        ),
                        Expanded(
                          child: VideoProgressIndicator(
                            controller,
                            allowScrubbing: true,
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            colors: VideoProgressColors(
                              playedColor: Color(secondaryCOLR),
                              bufferedColor: Color.fromRGBO(181, 77, 232, 0.35),
                              backgroundColor: Color.fromRGBO(255, 255, 255, 0.2),
                            ),
                          ),
                        ),
                        Text(
                          widget.trailer.durationLabel.isNotEmpty
                              ? widget.trailer.durationLabel
                              : _time(value.duration),
                          style: TextStyle(color: Colors.white, fontSize: 10),
                        ),
                        GestureDetector(
                          onTap: () =>
                              controller.setVolume(value.volume > 0 ? 0 : 1),
                          child: Icon(
                            value.volume > 0
                                ? Remix.volume_up_fill
                                : Remix.volume_mute_fill,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
