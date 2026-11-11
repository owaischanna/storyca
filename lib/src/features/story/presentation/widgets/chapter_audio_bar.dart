import 'dart:async';

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:remixicon/remixicon.dart';
import 'package:storryca/src/core/constants/colors.const.dart';
import 'package:storryca/src/core/constants/text_styyle.dart';
import 'package:storryca/src/core/network/api.dart';
import 'package:storryca/src/core/network/api_client.dart';
import 'package:storryca/src/core/network/repositories/audio_repository.dart';
import 'package:storryca/src/core/widgets/gradient_button.dart';

/// One player shared by every chapter on the reading screen — starting a
/// chapter stops whichever was playing. Owned and disposed by the reader.
class ChapterAudioPlayer {
  // Headers sent natively by Android's player rather than through
  // just_audio's local http://127.0.0.1 proxy, which this app's cleartext
  // policy blocks.
  final AudioPlayer player = AudioPlayer(useProxyForRequestHeaders: false);
  final ValueNotifier<int?> activeChapter = ValueNotifier(null);

  /// [url] is used exactly as given. When it points at storryca.com itself
  /// (the website's chapter-audio stream, which refuses anyone it can't
  /// recognise with "Please sign in to listen.") the reader's token, login
  /// cookie and User-Agent go with it; links on any other host (e.g. signed
  /// storage links) are sent bare, as before.
  Future<void> play(int chapterId, String url) async {
    if (activeChapter.value != chapterId) {
      await player.stop();
      activeChapter.value = chapterId;
      try {
        final host = Uri.tryParse(url)?.host ?? '';
        final ownSite =
            host == 'storryca.com' || host.endsWith('.storryca.com');
        await player.setUrl(
          url,
          headers: ownSite ? await apiClient.readerHeaders() : null,
        );
      } catch (_) {
        activeChapter.value = null;
        rethrow;
      }
    }
    // Not awaited: play()'s future only completes when playback stops.
    unawaited(player.play());
  }

  void pause() => player.pause();

  void dispose() {
    player.dispose();
    activeChapter.dispose();
  }
}

/// [needsBook]: a free chapter of a book that isn't unlocked — the text is
/// free, narration isn't (it's made by a paid service), so Listen is shown
/// explaining that instead of failing.
enum _AudioState { loading, hidden, notReady, preparing, ready, needsBook }

/// "Listen to this chapter", above the chapter text. Asks the server (GET,
/// free) whether narration exists. If it does, it plays. If not, a Listen
/// button asks the server to make it (POST) — the only call that can cost
/// money, so it is only ever sent from that button, never on load, never
/// retried automatically.
class ChapterAudioBar extends StatefulWidget {
  const ChapterAudioBar({
    super.key,
    required this.chapterId,
    required this.player,
  });

  final int chapterId;
  final ChapterAudioPlayer player;

  @override
  State<ChapterAudioBar> createState() => _ChapterAudioBarState();
}

class _ChapterAudioBarState extends State<ChapterAudioBar> {
  _AudioState _state = _AudioState.loading;
  ChapterAudio? _audio;
  String? _message;
  int _unavailableCount = 0;
  Timer? _recheck;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  @override
  void dispose() {
    _recheck?.cancel();
    super.dispose();
  }

  /// GET — reports only, makes nothing.
  Future<ChapterAudio?> _get() async {
    final token = await authService.getToken();
    if (token == null) return null;
    return audioRepository.chapter(widget.chapterId, token);
  }

  Future<void> _fetch() async {
    try {
      final audio = await _get();
      if (!mounted) return;
      setState(() {
        _audio = audio;
        _state = audio == null
            // Signed out: reading a free chapter, nothing unlocked.
            ? _AudioState.needsBook
            : audio.ready
            ? _AudioState.ready
            : _AudioState.notReady;
        if (audio == null) {
          _message = 'Sign in and unlock this book to listen.';
        }
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      if (e.isPaymentRequired) {
        // A free chapter of a book that isn't unlocked.
        setState(() {
          _state = _AudioState.needsBook;
          _message =
              "Listening needs the book unlocked — narration isn't "
              "included with the free chapters.";
        });
      } else {
        // 404 draft/unpublished, or a network failure — no audio controls
        // at all rather than an error on the reading page.
        setState(() => _state = _AudioState.hidden);
      }
    } catch (_) {
      if (mounted) setState(() => _state = _AudioState.hidden);
    }
    if (_audio?.pending ?? false) _waitUntilReady();
  }

  /// Narration still being made (the server answered `pending`): check with
  /// the free GET every 5 s, for up to 2 minutes, then play. Never POSTs.
  int _waits = 0;
  void _waitUntilReady() {
    _recheck?.cancel();
    if (_waits >= 24) {
      if (mounted) {
        setState(() {
          _state = _AudioState.notReady;
          _message = 'Not ready yet. You can press Listen again.';
        });
      }
      return;
    }
    _waits++;
    if (mounted) {
      setState(() {
        _state = _AudioState.preparing;
        _message = null;
      });
    }
    _recheck = Timer(const Duration(seconds: 5), () async {
      try {
        final audio = await _get();
        if (!mounted) return;
        if (audio?.ready ?? false) {
          setState(() {
            _audio = audio;
            _state = _AudioState.ready;
          });
          _play();
        } else if (audio?.pending ?? false) {
          _waitUntilReady();
        } else {
          setState(() {
            _audio = audio;
            _state = _AudioState.notReady;
            _message = 'Audio could not be prepared. Press Listen to try again.';
          });
        }
      } catch (_) {
        if (mounted) _waitUntilReady();
      }
    });
  }

  /// Fired ONLY by the reader pressing Listen.
  Future<void> _listen() async {
    if (_state == _AudioState.preparing) return;
    final token = await authService.getToken();
    if (token == null || !mounted) return;
    setState(() {
      _state = _AudioState.preparing;
      _message = null;
    });
    try {
      final audio = await audioRepository.generate(widget.chapterId, token);
      if (!mounted) return;
      setState(() {
        _audio = audio;
        _state = audio.ready ? _AudioState.ready : _AudioState.notReady;
      });
      if (audio.ready) {
        _play();
      } else {
        // Accepted but still being made — wait for it with free GETs.
        _waits = 0;
        _waitUntilReady();
      }
    } on ApiException catch (e) {
      if (!mounted) return;
      switch (e.statusCode) {
        case 409:
          // Someone pressed Listen a moment earlier — wait, then ONE GET.
          setState(() => _message = 'This chapter is already being prepared.');
          _recheck = Timer(const Duration(seconds: 20), _recheckOnce);
        case 429:
          // Allowance used up — show it, never retry, hide Listen for the
          // session.
          audioRepository.allowanceUsedUp = true;
          setState(() {
            _state = _AudioState.notReady;
            _message = e.message;
          });
        case 402:
          setState(() {
            _state = _AudioState.needsBook;
            _message =
                "Listening needs the book unlocked — narration isn't "
                "included with the free chapters.";
          });
        case 503:
          setState(() {
            _unavailableCount++;
            _state = _AudioState.notReady;
            _message = 'Audio is not available right now.';
          });
        default:
          if (e.isTimeout) {
            // The server may still finish it; check once (GET) later.
            setState(
              () => _message =
                  'This is taking longer than usual. Checking again shortly.',
            );
            _recheck = Timer(const Duration(seconds: 20), _recheckOnce);
          } else {
            setState(() {
              _state = _AudioState.notReady;
              _message = e.message;
            });
          }
      }
    } catch (_) {
      // An answer the app couldn't read — say so instead of going quiet.
      if (mounted) {
        setState(() {
          _state = _AudioState.notReady;
          _message = 'Audio is not available right now.';
        });
      }
    }
  }

  Future<void> _recheckOnce() async {
    try {
      final audio = await _get();
      if (!mounted) return;
      setState(() {
        _audio = audio;
        _state = (audio?.ready ?? false)
            ? _AudioState.ready
            : _AudioState.notReady;
        _message = (audio?.ready ?? false)
            ? null
            : 'Not ready yet. You can press Listen again.';
      });
      if (audio?.ready ?? false) _play();
    } on ApiException {
      if (mounted) setState(() => _state = _AudioState.notReady);
    }
  }

  Future<void> _play() async {
    var audio = _audio;
    if (audio == null) return;
    try {
      // Links die after 3 hours — fetch a fresh one rather than reuse it.
      if (audio.urlExpired || audio.audioUrl == null) {
        audio = await _get();
        if (!mounted || audio == null) return;
        setState(() => _audio = audio);
      }
      if (audio.audioUrl == null) return;
      await widget.player.play(widget.chapterId, audio.audioUrl!);
    } catch (_) {
      // A link that stopped working (expired mid-session answers 403):
      // one fresh link, one more try.
      try {
        final fresh = await _get();
        if (!mounted || fresh?.audioUrl == null) return;
        setState(() => _audio = fresh);
        await widget.player.play(widget.chapterId, fresh!.audioUrl!);
      } catch (_) {
        if (mounted) setState(() => _message = 'Couldn\'t play the audio.');
      }
    }
  }

  bool get _canListen =>
      !audioRepository.allowanceUsedUp && _unavailableCount < 2;

  @override
  Widget build(BuildContext context) {
    if (_state == _AudioState.hidden || _state == _AudioState.loading) {
      return const SizedBox.shrink();
    }
    final audio = _audio;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(
          width: 1,
          color: const Color.fromRGBO(181, 77, 232, 0.3),
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 10,
        children: [
          Row(
            spacing: 8,
            children: [
              ShaderMask(
                shaderCallback: (b) => defaultGradientTTB.createShader(b),
                child: const Icon(
                  Remix.volume_up_line,
                  color: Colors.white,
                  size: 18,
                ),
              ),
              const Expanded(
                child: Text(
                  'Listen to this chapter',
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),
              ),
              Text(
                _state == _AudioState.ready
                    ? (audio?.duration.isNotEmpty ?? false)
                          ? 'Ready · ${audio!.duration}'
                          : 'Ready'
                    : _state == _AudioState.preparing
                    ? 'Preparing…'
                    : _state == _AudioState.needsBook
                    ? 'Needs the book'
                    : 'Not made yet',
                style: defaultTextStyle10,
              ),
            ],
          ),
          if (_state == _AudioState.ready)
            _Controls(
              chapterId: widget.chapterId,
              player: widget.player,
              onPlay: _play,
            )
          else if (_state == _AudioState.preparing)
            Row(
              spacing: 10,
              children: [
                const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Color(0xffB54DE8),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Preparing the audio. This takes about twenty seconds the '
                    'first time, and it is instant for everyone afterwards.',
                    style: defaultTextStyle10,
                  ),
                ),
              ],
            )
          else if (_state == _AudioState.needsBook)
            Opacity(
              opacity: 0.5,
              child: SizedBox(
                height: 36,
                child: GradientButton(
                  label: 'Listen',
                  hasIcon: true,
                  icon: Remix.lock_2_line,
                  fontSize: 13,
                  iconSize: 16,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 6,
                  ),
                  onPressed: () {},
                ),
              ),
            )
          else if (_canListen)
            SizedBox(
              height: 36,
              child: GradientButton(
                label: 'Listen',
                hasIcon: true,
                icon: Remix.headphone_line,
                fontSize: 13,
                iconSize: 16,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 6,
                ),
                onPressed: _listen,
              ),
            ),
          if (_message != null)
            Text(
              _message!,
              style: TextStyle(color: Color(primaryTextCOLR), fontSize: 11),
            ),
        ],
      ),
    );
  }
}

class _Controls extends StatelessWidget {
  const _Controls({
    required this.chapterId,
    required this.player,
    required this.onPlay,
  });

  final int chapterId;
  final ChapterAudioPlayer player;
  final VoidCallback onPlay;

  static String _time(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60).toString().padLeft(h > 0 ? 2 : 1, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return h > 0 ? '$h:$m:$s' : '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int?>(
      valueListenable: player.activeChapter,
      builder: (context, active, _) {
        final isActive = active == chapterId;
        return StreamBuilder<PlayerState>(
          stream: player.player.playerStateStream,
          builder: (context, stateSnap) {
            final state = stateSnap.data;
            final playing =
                isActive &&
                (state?.playing ?? false) &&
                state?.processingState != ProcessingState.completed;
            final buffering =
                isActive &&
                (state?.processingState == ProcessingState.loading ||
                    state?.processingState == ProcessingState.buffering);
            return Row(
              spacing: 8,
              children: [
                GestureDetector(
                  onTap: () {
                    if (playing) {
                      player.pause();
                    } else if (isActive &&
                        state?.processingState == ProcessingState.completed) {
                      player.player.seek(Duration.zero);
                      player.player.play();
                    } else {
                      onPlay();
                    }
                  },
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      gradient: defaultGradientTTB,
                      shape: BoxShape.circle,
                    ),
                    child: buffering
                        ? const Padding(
                            padding: EdgeInsets.all(10),
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Icon(
                            playing ? Remix.pause_fill : Remix.play_fill,
                            color: Colors.white,
                            size: 20,
                          ),
                  ),
                ),
                Expanded(
                  child: StreamBuilder<Duration>(
                    stream: player.player.positionStream,
                    builder: (context, posSnap) {
                      final total = isActive
                          ? (player.player.duration ?? Duration.zero)
                          : Duration.zero;
                      final pos = isActive
                          ? (posSnap.data ?? Duration.zero)
                          : Duration.zero;
                      final max = total.inMilliseconds.toDouble();
                      return Row(
                        children: [
                          Expanded(
                            child: SliderTheme(
                              data: SliderTheme.of(context).copyWith(
                                trackHeight: 2,
                                thumbShape: const RoundSliderThumbShape(
                                  enabledThumbRadius: 6,
                                ),
                                overlayShape: SliderComponentShape.noOverlay,
                                activeTrackColor: const Color(0xffB54DE8),
                                inactiveTrackColor: const Color.fromRGBO(
                                  181,
                                  77,
                                  232,
                                  0.2,
                                ),
                                thumbColor: Colors.white,
                              ),
                              child: Slider(
                                min: 0,
                                max: max > 0 ? max : 1,
                                value: max > 0
                                    ? pos.inMilliseconds
                                          .clamp(0, max.toInt())
                                          .toDouble()
                                    : 0,
                                // Seeking uses HTTP Range on the server.
                                onChanged: isActive && max > 0
                                    ? (v) => player.player.seek(
                                        Duration(milliseconds: v.round()),
                                      )
                                    : null,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            isActive && max > 0
                                ? '${_time(pos)} / ${_time(total)}'
                                : '',
                            style: defaultTextStyle10,
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
