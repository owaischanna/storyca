import 'package:storryca/src/core/widgets/branded_refresh_indicator.dart';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:remixicon/remixicon.dart';
import 'package:storryca/src/core/constants/colors.const.dart';
import 'package:storryca/src/core/constants/images.const.dart';
import 'package:storryca/src/core/constants/text_styyle.dart';
import 'package:storryca/src/core/network/api.dart';
import 'package:storryca/src/core/network/api_client.dart';
import 'package:storryca/src/core/network/image_url.dart';
import 'package:storryca/src/core/network/models/author_api_model.dart';
import 'package:storryca/src/core/network/models/story_api_model.dart';
import 'package:storryca/src/core/widgets/app_image.dart';
import 'package:storryca/src/core/widgets/app_snackbar.dart';
import 'package:storryca/src/core/widgets/moderation_actions.dart';
import 'package:storryca/src/core/widgets/error_state.dart';
import 'package:storryca/src/core/widgets/gradient_button.dart';
import 'package:storryca/src/core/widgets/loading_state.dart';
import 'package:storryca/src/features/story/presentation/widgets/story_chapters_tab.dart';
import 'package:storryca/src/features/story/presentation/widgets/story_recommended_tab.dart';
import 'package:storryca/src/features/story/presentation/widgets/story_reviews_tab.dart';
import 'package:storryca/src/features/story/presentation/widgets/story_unlocked.dart';
import 'package:storryca/src/features/story/presentation/widgets/unlock_story.dart';
import 'package:storryca/src/features/story/presentation/widgets/unlock_story_footer.dart';

class Story extends StatefulWidget {
  const Story({super.key, required this.id});

  final int id;

  @override
  State<Story> createState() => _StoryState();
}

/// Defers building (and thus loading the data of) a `TabBarView` child until
/// its tab is actually selected. `TabBarView` otherwise builds every child
/// up front, which meant opening a story fired off the chapters, reviews,
/// and recommended-stories network calls all at once — alongside the
/// story/author/saved-status calls already in flight — piling up requests
/// on a shared-hosting backend and making the very first open feel slow.
class _LazyTab extends StatefulWidget {
  const _LazyTab({required this.index, required this.builder});

  final int index;
  final WidgetBuilder builder;

  @override
  State<_LazyTab> createState() => _LazyTabState();
}

class _LazyTabState extends State<_LazyTab>
    with AutomaticKeepAliveClientMixin {
  bool _visited = false;
  TabController? _controller;

  @override
  bool get wantKeepAlive => _visited;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final controller = DefaultTabController.of(context);
    if (_controller != controller) {
      _controller?.removeListener(_onTabChange);
      _controller = controller..addListener(_onTabChange);
    }
    if (controller.index == widget.index) _visited = true;
  }

  void _onTabChange() {
    if (_controller?.index == widget.index && !_visited) {
      setState(() => _visited = true);
    }
  }

  @override
  void dispose() {
    _controller?.removeListener(_onTabChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return _visited ? widget.builder(context) : const SizedBox.shrink();
  }
}

class _StoryState extends State<Story> {
  bool isInLibary = false;
  bool isLiked = false;
  bool _libraryUpdating = false;

  StoryApiModel? _story;
  AuthorApiModel? _author;
  String? _error;
  String? _token;

  /// Whether the book has been unlocked — derived from whether its
  /// chapters come back locked, not tracked as separate client state, so it
  /// can never drift from what the server actually charged for.
  bool _isUnlocked = false;

  /// True once chapter data has loaded and the book turns out to have no
  /// published chapters at all — the unlock button is hidden in that case,
  /// matching the website (there is nothing to buy).
  bool _hasNoChapters = false;

  /// The book's price in coins, from the wallet — never hard-coded, so a
  /// price change on the server shows up without an app release.
  num? _bookPrice;
  bool _unlocking = false;
  bool _authorMuted = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  /// Bumped on pull-to-refresh so [UnlockStoryFooter] is rebuilt and
  /// re-fetches the wallet balance from the backend.
  int _refreshTick = 0;

  Future<void> _refresh() async {
    setState(() => _refreshTick++);
    await _load();
  }

  Future<void> _load() async {
    setState(() => _error = null);
    _token = await authService.getToken();
    try {
      final story = await storiesRepository.byId(widget.id);
      final token = _token;
      final results = await Future.wait<dynamic>([
        story.authorId != 0
            ? authorsRepository.byId(story.authorId)
            : Future.value(null),
        if (token != null)
          libraryRepository.isSaved(story.id, token).catchError((_) {
            // save-state is a nice-to-have; keep the default rather than
            // blocking the whole page on it.
            return false;
          }),
      ]);
      final author = results[0] as AuthorApiModel?;
      final saved = token != null ? results[1] as bool : false;
      setState(() {
        _story = story;
        _author = author;
        isInLibary = saved;
      });
      if (story.authorId != 0) {
        ModerationActions.isMuted(story.authorId).then((muted) {
          if (mounted) setState(() => _authorMuted = muted);
        });
      }
      await _loadUnlockState(token);
      // Fire-and-forget: never block showing the story on this, and the
      // server itself ignores repeat views the same day / from the story's
      // own author.
      deviceService.getDeviceId().then((deviceId) {
        storiesRepository.recordView(
          storyId: story.id,
          deviceId: deviceId,
          token: token,
        );
      });
    } on ApiException catch (e) {
      setState(() => _error = e.message);
    }
  }

  Future<void> _toggleLibrary() async {
    final token = _token;
    final story = _story;
    if (token == null) {
      AppSnackbar.warning(context, 'Sign in to save stories to your library.');
      return;
    }
    if (story == null || _libraryUpdating) return;
    setState(() => _libraryUpdating = true);
    try {
      if (isInLibary) {
        await libraryRepository.unsave(story.id, token);
      } else {
        await libraryRepository.save(story.id, token);
      }
      setState(() => isInLibary = !isInLibary);
    } on ApiException catch (e) {
      if (mounted) AppSnackbar.error(context, e.message);
    } finally {
      if (mounted) setState(() => _libraryUpdating = false);
    }
  }

  void toogleLikeStory() {
    setState(() {
      isLiked = !isLiked;
    });
  }

  /// Chapters come back with a shared `locked` flag for the whole book, and
  /// an empty book (nothing published) hides the unlock button entirely —
  /// this is the one call that decides both.
  Future<void> _loadUnlockState(String? token) async {
    try {
      final chapters = await chaptersRepository.byStoryId(
        widget.id,
        token: token,
      );
      if (!mounted) return;
      setState(() {
        _hasNoChapters = chapters.isEmpty;
        // Only real chapter data can say a book is unlocked — an empty
        // chapter list means "nothing to unlock", not "already unlocked",
        // so this must not fall back to true just because there's nothing
        // to check yet (that previously made the empty-book case render as
        // if it were unlocked instead of being hidden below).
        _isUnlocked = chapters.isNotEmpty && !chapters.first.locked;
      });
    } on ApiException {
      // Non-fatal: the story itself already loaded, so leave the unlock
      // panel showing rather than blocking the whole page on this.
    }
    if (token == null) return;
    try {
      final wallet = await walletRepository.getWallet(token);
      if (mounted) setState(() => _bookPrice = wallet.bookPrice);
    } on ApiException {
      // Price display is best-effort; the unlock call itself still enforces
      // the real price server-side.
    }
  }

  Future<void> unlockStory() async {
    final token = _token;
    if (token == null) {
      AppSnackbar.warning(context, 'Sign in to unlock this book.');
      return;
    }
    if (_unlocking) return;
    setState(() => _unlocking = true);
    try {
      await walletRepository.unlock(widget.id, token);
      if (!mounted) return;
      setState(() {
        _isUnlocked = true;
        _unlocking = false;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _unlocking = false);
      if (e.isPaymentRequired) {
        AppSnackbar.warning(context, e.message);
        context.push('/topup');
      } else {
        AppSnackbar.error(context, e.message);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return Scaffold(
        backgroundColor: Color(0xFF020004),
        body: SafeArea(child: ErrorState(message: _error!, onRetry: _load)),
      );
    }
    if (_story == null) {
      return Scaffold(
        backgroundColor: Color(0xFF020004),
        body: const SafeArea(child: LoadingState()),
      );
    }
    final story = _story!;
    final author = _author;
    return Scaffold(
      backgroundColor: Color(0xFF020004),
      body: Container(
        decoration: BoxDecoration(gradient: pageGradientCOLR),
        child: BrandedRefreshIndicator(
          onRefresh: _refresh,
          child: SafeArea(
            child: Column(
              spacing: 16,
              children: [
                // HEADER
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: () {
                          context.pop();
                        },
                        icon: Icon(Remix.arrow_left_s_line),
                        color: Colors.white,
                        iconSize: 24,
                      ),
                      Row(
                        spacing: 0,
                        children: [
                          IconButton(
                            onPressed: () {},
                            icon: Icon(Remix.share_fill),
                            color: Colors.white,
                            iconSize: 24,
                          ),
                          PopupMenuButton(
                            icon: Icon(
                              Remix.more_2_line,
                              size: 24,
                              color: Colors.white,
                            ),
                            color: Color.fromRGBO(23, 0, 45, 0.9),
                            menuPadding: EdgeInsets.all(0),
                            shape: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(width: 0),
                            ),
                            position: PopupMenuPosition.under,
                            onSelected: (value) async {
                              if (value == 'mute') {
                                final muted =
                                    await ModerationActions.toggleMute(
                                      context,
                                      userId: story.authorId,
                                      currentlyMuted: _authorMuted,
                                    );
                                if (muted != null && mounted) {
                                  setState(() => _authorMuted = muted);
                                }
                              } else if (value == 'report') {
                                ModerationActions.report(
                                  context,
                                  targetType: 'story',
                                  targetId: story.id,
                                );
                              }
                              // 'block' stays inert until blocking is built.
                            },
                            itemBuilder: (context) {
                              return [
                                PopupMenuItem(
                                  height: 40,
                                  value: 'share',
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    spacing: 8,
                                    children: [
                                      Icon(
                                        Remix.share_line,
                                        color: Colors.white,
                                        size: 16,
                                      ),
                                      Text(
                                        'Share',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                PopupMenuItem(
                                  height: 40,
                                  value: 'mute',
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    spacing: 8,
                                    children: [
                                      Icon(
                                        _authorMuted
                                            ? Remix.notification_line
                                            : Remix.notification_off_line,
                                        color: Colors.white,
                                        size: 16,
                                      ),
                                      Text(
                                        _authorMuted
                                            ? 'Unmute Updates'
                                            : 'Mute Updates',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                PopupMenuItem(
                                  height: 40,
                                  value: 'report',
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    spacing: 8,
                                    children: [
                                      Icon(
                                        Remix.flag_line,
                                        color: Colors.white,
                                        size: 16,
                                      ),
                                      Text(
                                        'Report',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                PopupMenuItem(
                                  height: 40,
                                  value: 'block',
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    spacing: 8,
                                    children: [
                                      Icon(
                                        Remix.user_unfollow_line,
                                        color: Color(0xffC23B3B),
                                        size: 16,
                                      ),
                                      Text(
                                        'Block Author',
                                        style: TextStyle(
                                          color: Color(0xffC23B3B),
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ];
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // HERO
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    spacing: 16,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: AppImage(
                          coverUrl(story.cover, fallbackAsset: noStoryIMG),
                          width: 100,
                          height: 134,
                        ),
                      ),
                      Expanded(
                        child: Column(
                          spacing: 8,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              story.title,
                              style: GoogleFonts.playfair(
                                color: Colors.white,
                                fontSize: 18,
                              ),
                            ),
                            Row(
                              spacing: 8,
                              children: [
                                ShaderMask(
                                  shaderCallback: (bounds) {
                                    return defaultGradientTTB.createShader(
                                      bounds,
                                    );
                                  },
                                  child: Icon(
                                    Remix.leaf_fill,
                                    color: Colors.white,
                                    size: 14,
                                  ),
                                ),
                                Text(story.authorName, style: defaultTextStyle),
                              ],
                            ),
                            Row(
                              spacing: 8,
                              children: [
                                Row(
                                  spacing: 4,
                                  children: [
                                    ...List.generate(story.ratings.round(), (
                                      index,
                                    ) {
                                      return ShaderMask(
                                        shaderCallback: (bounds) {
                                          return defaultGradientTTB
                                              .createShader(bounds);
                                        },
                                        child: Icon(
                                          Remix.star_fill,
                                          color: Colors.white,
                                          size: 16,
                                        ),
                                      );
                                    }),
                                    ...List.generate(
                                      5 - story.ratings.round(),
                                      (index) {
                                        return Icon(
                                          Remix.star_fill,
                                          color: Color(0xFF332B42),
                                          size: 16,
                                        );
                                      },
                                    ),
                                  ],
                                ),
                                Text(
                                  story.ratings > 0
                                      ? story.ratings.toStringAsFixed(1)
                                      : 'No ratings yet',
                                  style: defaultTextStyle,
                                ),
                              ],
                            ),
                            Row(
                              spacing: 16,
                              children: [
                                Container(
                                  padding: EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      width: 0.5,
                                      color: Color(0xffC384FF),
                                    ),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    story.genre,
                                    style: TextStyle(
                                      color: Color(0xffC384FF),
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // STORY ACTION
                // Nothing to unlock and nothing to read yet — the website
                // hides this entirely for an empty book rather than showing
                // an unlock button (or, as it was doing here, a "Start
                // Reading" button for chapters that don't exist).
                if (!_hasNoChapters)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Visibility(
                      visible: _isUnlocked,
                      replacement: UnlockStory(
                        unlockStory: unlockStory,
                        price: _bookPrice,
                        unlocking: _unlocking,
                      ),
                      child: StoryUnlocked(storyId: story.id),
                    ),
                  ),

                // INFO
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        spacing: 8,
                        children: [
                          ShaderMask(
                            shaderCallback: (bounds) {
                              return defaultGradientTTB.createShader(bounds);
                            },
                            child: Icon(
                              Remix.booklet_line,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          Column(
                            children: [
                              Text('${story.chapters}', style: whiteF14TS),
                              Text('Chapters', style: defaultTextStyle),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 70,
                        child: VerticalDivider(
                          color: Color.fromRGBO(181, 77, 232, 0.1),
                        ),
                      ),
                      Column(
                        spacing: 8,
                        children: [
                          ShaderMask(
                            shaderCallback: (bounds) {
                              return defaultGradientTTB.createShader(bounds);
                            },
                            child: Icon(
                              Remix.eye_line,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          Column(
                            children: [
                              Text('${story.views}', style: whiteF14TS),
                              Text('Views', style: defaultTextStyle),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 70,
                        child: VerticalDivider(
                          color: Color.fromRGBO(181, 77, 232, 0.1),
                        ),
                      ),
                      Column(
                        spacing: 8,
                        children: [
                          ShaderMask(
                            shaderCallback: (bounds) {
                              return defaultGradientTTB.createShader(bounds);
                            },
                            child: Icon(
                              Remix.booklet_line,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          Column(
                            children: [
                              Text('${story.reads}', style: whiteF14TS),
                              Text('Reads', style: defaultTextStyle),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 70,
                        child: VerticalDivider(
                          color: Color.fromRGBO(181, 77, 232, 0.1),
                        ),
                      ),
                      Column(
                        spacing: 8,
                        children: [
                          ShaderMask(
                            shaderCallback: (bounds) {
                              return defaultGradientTTB.createShader(bounds);
                            },
                            child: Icon(
                              Remix.calendar_line,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          Column(
                            children: [
                              Text(story.state, style: whiteF14TS),
                              Text('Status', style: defaultTextStyle),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // EXTRAS
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    spacing: 16,
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 40,
                          child: GradientButton(
                            label: _libraryUpdating
                                ? 'Saving…'
                                : isInLibary
                                ? 'Remove From Library'
                                : 'Add to Library',
                            hasIcon: true,
                            icon: isInLibary
                                ? Remix.bookmark_fill
                                : Remix.bookmark_line,
                            radius: 8,
                            padding: EdgeInsets.symmetric(
                              vertical: 6,
                              horizontal: 8,
                            ),
                            onPressed: _toggleLibrary,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => toogleLikeStory(),
                        child: Row(
                          spacing: 8,
                          children: [
                            Visibility(
                              visible: !isLiked,
                              replacement: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    width: 1,
                                    color: Color(0xFF9110DE),
                                  ),
                                  borderRadius: BorderRadius.circular(100),
                                ),
                                child: Center(
                                  child: ShaderMask(
                                    shaderCallback: (bounds) {
                                      return defaultGradientTTB.createShader(
                                        bounds,
                                      );
                                    },
                                    child: Icon(
                                      Remix.heart_2_line,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                ),
                              ),
                              child: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    width: 1,
                                    color: Color.fromRGBO(181, 77, 232, 0.1),
                                  ),
                                  borderRadius: BorderRadius.circular(100),
                                ),
                                child: Center(
                                  child: Icon(
                                    Remix.heart_2_line,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ),
                            if (!isLiked) Text('Like', style: whiteF16TS),
                            if (isLiked) Text('Liked', style: secondaryF16TS),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // SEPERATER
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Divider(color: Color.fromRGBO(181, 77, 232, 0.1)),
                ),

                // ABOUT
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Color.fromRGBO(181, 77, 232, 0.1),
                      border: Border.all(
                        width: 1,
                        color: Color.fromRGBO(181, 77, 232, 0.1),
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      spacing: 8,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Synopsis',
                          style: GoogleFonts.playfair(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                        Text(story.summary, style: defaultTextStyle),
                      ],
                    ),
                  ),
                ),

                // AUTHOR
                if (author != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Color.fromRGBO(181, 77, 232, 0.1),
                        border: Border.all(
                          width: 1,
                          color: Color.fromRGBO(181, 77, 232, 0.1),
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        spacing: 8,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'About the Author',
                                style: GoogleFonts.playfair(
                                  fontSize: 14,
                                  color: Colors.white,
                                ),
                              ),
                              GestureDetector(
                                onTap: () =>
                                    context.push('/author-profile/${author.id}'),
                                child: Icon(
                                  Remix.arrow_right_s_line,
                                  size: 18,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => context.push(
                                    '/author-profile/${author.id}',
                                  ),
                                  child: Row(
                                    spacing: 8,
                                    children: [
                                      Container(
                                        width: 62,
                                        height: 62,
                                        padding: EdgeInsets.all(2),
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                            colors: [
                                              Color(0xFFEECAFF),
                                              Color(0xFF520E92),
                                            ],
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            62,
                                          ),
                                        ),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            60,
                                          ),
                                          child: AppImage(
                                            avatarUrl(author.image),
                                            width: 60,
                                            height: 60,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Column(
                                          spacing: 2,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              author.name,
                                              style: GoogleFonts.playfair(
                                                color: Colors.white,
                                                fontSize: 16,
                                              ),
                                            ),
                                            Text(
                                              '@${author.username}',
                                              style: defaultTextStyle10,
                                            ),
                                            Text(
                                              author.aboutMe,
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style: defaultTextStyle,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Column(
                                spacing: 8,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      vertical: 5,
                                      horizontal: 10,
                                    ),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        width: 0.5,
                                        color: Color(secondaryCOLR),
                                      ),
                                      borderRadius: BorderRadius.circular(3),
                                    ),
                                    child: Row(
                                      spacing: 4,
                                      children: [
                                        Icon(
                                          Remix.group_line,
                                          color: Color(secondaryCOLR),
                                          size: 16,
                                        ),
                                        Text('Follow', style: secondaryF12TS),
                                      ],
                                    ),
                                  ),
                                  Row(
                                    spacing: 4,
                                    children: [
                                      Column(
                                        children: [
                                          Text(
                                            '${author.followers}',
                                            style: whiteF14TS,
                                          ),
                                          Text(
                                            'Followers',
                                            style: defaultTextStyle10,
                                          ),
                                        ],
                                      ),
                                      SizedBox(
                                        height: 30,
                                        child: VerticalDivider(
                                          color: Color.fromRGBO(
                                            181,
                                            77,
                                            232,
                                            0.1,
                                          ),
                                        ),
                                      ),
                                      Column(
                                        children: [
                                          Text(
                                            '${author.publishedStories}',
                                            style: whiteF14TS,
                                          ),
                                          Text(
                                            'Stories',
                                            style: defaultTextStyle10,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                // TABBARS AND TABS
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.6,
                  child: DefaultTabController(
                    length: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: TabBar(
                            padding: EdgeInsets.all(0),
                            dividerColor: Color.fromRGBO(157, 138, 197, 0.2),
                            indicatorColor: Color(secondaryCOLR),
                            indicatorSize: TabBarIndicatorSize.tab,
                            labelStyle: TextStyle(
                              color: Color(secondaryCOLR),
                              fontSize: 12,
                            ),
                            unselectedLabelStyle: TextStyle(
                              color: Color(primaryTextCOLR),
                              fontSize: 12,
                            ),
                            isScrollable: true,
                            tabAlignment: TabAlignment.start,
                            tabs: [
                              Tab(
                                child: Row(
                                  spacing: 8,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Remix.booklet_line, size: 14),
                                    Text(
                                      'Chapters(${story.chapters})',
                                      style: TextStyle(fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                              Tab(
                                child: Row(
                                  spacing: 8,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Remix.star_line, size: 14),
                                    Text(
                                      'Reviews',
                                      style: TextStyle(fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                              Tab(
                                child: Row(
                                  spacing: 8,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Remix.list_unordered, size: 14),
                                    Text(
                                      'Recommended',
                                      style: TextStyle(fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: TabBarView(
                            children: [
                              _LazyTab(
                                index: 0,
                                builder: (_) =>
                                    StoryChaptersTab(storyId: story.id),
                              ),
                              _LazyTab(
                                index: 1,
                                builder: (_) =>
                                    StoryReviewsTab(storyId: story.id),
                              ),
                              _LazyTab(
                                index: 2,
                                builder: (_) => StoryRecommendedTab(
                                  storyId: story.id,
                                  genre: story.genre,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // SPACING
                SizedBox(height: 50),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: (_isUnlocked || _hasNoChapters)
          ? SizedBox.shrink()
          : UnlockStoryFooter(
              key: ValueKey(_refreshTick),
              price: _bookPrice,
              unlocking: _unlocking,
              onUnlock: unlockStory,
            ),
    );
  }
}
