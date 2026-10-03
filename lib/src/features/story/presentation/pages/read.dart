import 'package:storryca/src/core/network/models/story_api_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:storryca/src/core/constants/colors.const.dart';
import 'package:storryca/src/core/network/api.dart';
import 'package:storryca/src/core/network/api_client.dart';
import 'package:storryca/src/core/network/models/chapter_api_model.dart';
import 'package:storryca/src/core/widgets/error_state.dart';
import 'package:storryca/src/core/widgets/loading_state.dart';
import 'package:storryca/src/core/widgets/moderation_actions.dart';
import 'package:storryca/src/features/story/presentation/widgets/chapters_side_panel.dart';
import 'package:storryca/src/features/story/presentation/widgets/read_mode_appbar.dart';
import 'package:storryca/src/features/story/presentation/widgets/story_read_item.dart';

class Read extends StatefulWidget {
  const Read({super.key, required this.id});

  final int id;

  @override
  State<Read> createState() => _ReadState();
}

class _ReadState extends State<Read> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final ScrollController _scrollController = ScrollController();
  bool showAppBar = true;

  ChapterApiModel? _chapter;
  StoryApiModel? _story;
  bool _authorMuted = false;

  /// Reader's position through the whole story, shown in the app bar.
  int _percent = 0;
  bool _disposed = false;
  List<ChapterApiModel> _siblings = [];
  int _visibleCount = 1;
  String? _error;

  /// Set when [_error] came from a 402 — this book hasn't been unlocked, not
  /// some other failure, so the reader is sent back to the book screen's
  /// unlock panel instead of offered a "retry".
  bool _locked = false;

  String? _token;

  /// Index of the chapter this screen was opened on, within the story's
  /// full chapter list, and how many chapters the story has in total. Used
  /// (like the website's read-book.js) to express progress as "chapter N of
  /// M" rather than a scroll-position fraction, so the story is only ever
  /// marked complete on actually finishing its last chapter.
  int _chapterIndex = 0;
  int _totalChapters = 1;

  /// Dedupes progress calls by "chapterId:percent" so re-entering the same
  /// milestone (e.g. re-scrolling to the bottom) doesn't re-send it.
  final Set<String> _sentProgress = {};

  @override
  void initState() {
    super.initState();

    // HIDE TOP AND BOTTOM SYSTEM UI
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    _scrollController.addListener(_onScroll);
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _error = null;
      _locked = false;
    });
    _token = await authService.getToken();
    try {
      final chapter = await chaptersRepository.byId(widget.id, token: _token);
      if (chapter == null) {
        setState(() => _error = 'Chapter not found.');
        return;
      }
      final results = await Future.wait<Object?>([
        chaptersRepository.byStoryId(chapter.storyId, token: _token),
        storiesRepository.byId(chapter.storyId).then<StoryApiModel?>(
          (s) => s,
          onError: (_) => null,
        ),
      ]);
      final siblings = results[0] as List<ChapterApiModel>;
      _story = results[1] as StoryApiModel?;
      final authorId = _story?.authorId ?? 0;
      if (authorId != 0) {
        ModerationActions.isMuted(authorId).then((muted) {
          if (mounted) setState(() => _authorMuted = muted);
        });
      }
      final startIndex = siblings.indexWhere((c) => c.id == chapter.id);
      setState(() {
        _chapter = chapter;
        _chapterIndex = startIndex == -1 ? 0 : startIndex;
        _totalChapters = siblings.isEmpty ? 1 : siblings.length;
        _siblings = startIndex == -1
            ? [chapter]
            : siblings.sublist(startIndex);
        _visibleCount = 1;
      });
      // Opening the chapter is itself progress worth recording — this is
      // what makes the "Continue Reading" position move, not just the
      // read counter below. Previously nothing was sent until the reader
      // scrolled, so a chapter opened and closed without scrolling (or one
      // short enough to need no scrolling — handled by the post-frame check
      // below) never counted as progress at all.
      _recordProgress(globalIndex: _chapterIndex, finished: false);
      WidgetsBinding.instance.addPostFrameCallback((_) => _maybeRecordFinished());
      _recordReadCount(chapter);
    } on ApiException catch (e) {
      setState(() {
        _error = e.message;
        _locked = e.isPaymentRequired;
      });
    }
  }

  void _onScroll() {
    _maybeLoadNextChapter();
    _maybeRecordFinished();
  }

  void _maybeLoadNextChapter() {
    if (_visibleCount >= _siblings.length) return;
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 300) {
      setState(() => _visibleCount++);
      _recordProgress(
        globalIndex: _chapterIndex + _visibleCount - 1,
        finished: false,
      );
      _recordReadCount(_siblings[_visibleCount - 1]);
    }
  }

  /// Counts this chapter's story as "read" server-side — once per person
  /// per story ever, so it's safe (and intended) to call on every chapter
  /// actually shown, not just the first.
  void _recordReadCount(ChapterApiModel chapter) {
    deviceService.getDeviceId().then((deviceId) {
      storiesRepository.recordRead(
        storyId: chapter.storyId,
        chapterId: chapter.id,
        deviceId: deviceId,
        token: _token,
      );
    });
  }

  /// Mirrors the website's `atEnd()` check: once the bottom of the loaded
  /// content has scrolled into view, the currently-visible chapter counts
  /// as read.
  void _maybeRecordFinished() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    if (position.maxScrollExtent > 0 &&
        position.pixels < position.maxScrollExtent - 80) {
      return;
    }
    _recordProgress(
      globalIndex: _chapterIndex + _visibleCount - 1,
      finished: true,
    );
  }

  /// Sends `chapterIndex`/`totalChapters` (or `+1` when [finished]) as the
  /// story's overall percent, matching read-book.js's `openedPercent`/
  /// `finishedPercent` — reaching the end of the last chapter is what marks
  /// the whole story completed server-side.
  void _recordProgress({required int globalIndex, required bool finished}) {
    final token = _token;
    final localIndex = globalIndex - _chapterIndex;
    if (localIndex < 0 || localIndex >= _siblings.length) return;
    final chapter = _siblings[localIndex];
    final numerator = finished ? globalIndex + 1 : globalIndex;
    final percent = ((numerator / _totalChapters) * 100).clamp(0, 100).round();
    if (percent > _percent && !_disposed) setState(() => _percent = percent);
    if (token == null) return;
    final key = '${chapter.id}:$percent';
    if (!_sentProgress.add(key)) return;
    libraryRepository
        .saveProgress(
          storyId: chapter.storyId,
          chapterId: chapter.id,
          percent: percent,
          token: token,
        )
        .catchError((_) {
          // Best-effort — a failed save shouldn't interrupt reading, and a
          // later scroll/open can still record the same milestone.
          _sentProgress.remove(key);
        });
  }

  void toggleAppbar() {
    setState(() {
      showAppBar = !showAppBar;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: showAppBar
          ? ReadModeAppbar(
              scaffoldKey: _scaffoldKey,
              toggleAppbar: toggleAppbar,
              title: _story?.title ?? '',
              author: _story?.authorName ?? '',
              percent: _percent,
              authorMuted: _authorMuted,
              onMute: () async {
                final story = _story;
                if (story == null || story.authorId == 0) return;
                final muted = await ModerationActions.toggleMute(
                  context,
                  userId: story.authorId,
                  currentlyMuted: _authorMuted,
                );
                if (muted != null && mounted) {
                  setState(() => _authorMuted = muted);
                }
              },
              onReport: () {
                final story = _story;
                if (story == null) return;
                ModerationActions.report(
                  context,
                  targetType: 'story',
                  targetId: story.id,
                );
              },
            )
          : null,
      backgroundColor: Color(0xFF020004),
      body: Container(
        decoration: BoxDecoration(gradient: pageGradientCOLR),
        child: SingleChildScrollView(
          controller: _scrollController,
          child: SafeArea(
            child: GestureDetector(
              onDoubleTap: () => toggleAppbar(),
              child: Column(
                spacing: 16,
                children: [
                  // SPACING
                  SizedBox(height: 32),

                  // STORY
                  if (_error != null)
                    ErrorState(
                      message: _error!,
                      onRetry: _locked ? () => context.pop() : _load,
                      label: _locked ? 'Go to Book' : 'Retry',
                      height: 300,
                    )
                  else if (_chapter == null)
                    const LoadingState(height: 300)
                  else
                    ..._siblings.take(_visibleCount).map((chapter) {
                      return StoryReadItem(
                        title: chapter.title,
                        chapter: '${chapter.orderIndex}',
                        content: chapter.body,
                      );
                    }),
                ],
              ),
            ),
          ),
        ),
      ),
      endDrawer: _chapter == null
          ? null
          : Drawer(
              width: MediaQuery.of(context).size.width * 1,
              child: ChaptersSidePanel(
                chapters: _siblings,
                currentChapterId: _chapter!.id,
              ),
            ),
    );
  }

  @override
  void dispose() {
    _disposed = true;
    _maybeRecordFinished();
    _scrollController.dispose();
    super.dispose();

    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );
  }
}
