import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';
import 'package:storryca/src/core/constants/colors.const.dart';
import 'package:storryca/src/core/constants/text_styyle.dart';
import 'package:storryca/src/core/network/api.dart';
import 'package:storryca/src/core/network/api_client.dart';
import 'package:storryca/src/core/network/models/review_api_model.dart';
import 'package:storryca/src/core/network/repositories/reviews_repository.dart';
import 'package:storryca/src/core/widgets/app_snackbar.dart';
import 'package:storryca/src/core/widgets/custom_field.dart';
import 'package:storryca/src/core/widgets/error_state.dart';
import 'package:storryca/src/core/widgets/loading_state.dart';
import 'package:storryca/src/features/story/presentation/widgets/no_story_review.dart';
import 'package:storryca/src/features/story/presentation/widgets/story_review_item.dart';

class StoryReviewsTab extends StatefulWidget {
  const StoryReviewsTab({super.key, required this.storyId});

  final int storyId;

  @override
  State<StoryReviewsTab> createState() => _StoryReviewsTabState();
}

class _StoryReviewsTabState extends State<StoryReviewsTab> {
  String? _token;
  List<ReviewApiModel>? _reviews;
  RatingSummaryApiModel? _summary;
  int _page = 1;
  bool _hasMore = false;
  bool _loadingMore = false;
  String? _error;

  bool _deleting = false;

  /// From GET /reviews/mine — null means the reader hasn't rated yet, so
  /// their next post must be a starred review; otherwise it's a plain
  /// comment with no rating.
  ReviewApiModel? _myReview;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load({bool loadMore = false}) async {
    setState(() => _error = null);
    if (!loadMore) _token = await authService.getToken();
    final page = loadMore ? _page + 1 : 1;
    setState(() {
      if (loadMore) _loadingMore = true;
    });
    try {
      final token = _token;
      final results = await Future.wait<dynamic>([
        reviewsRepository.list(widget.storyId, page: page, token: token),
        if (!loadMore && token != null)
          reviewsRepository.mine(widget.storyId, token),
      ]);
      final result = results[0] as ReviewsPage;
      if (!loadMore) {
        _myReview = token == null ? null : results[1] as ReviewApiModel?;
      }
      if (!mounted) return;
      setState(() {
        _reviews = loadMore ? [...?_reviews, ...result.items] : result.items;
        _summary = result.summary;
        _page = result.pagination.page;
        _hasMore = result.pagination.hasMore;
      });
    } on ApiException catch (e) {
      setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _loadingMore = false);
    }
  }

  Future<void> _submitReview(
    BuildContext sheetContext,
    int rating,
    String body,
  ) async {
    final token = _token;
    if (token == null) {
      AppSnackbar.warning(context, 'Sign in to write a review.');
      return;
    }
    await _post(
      sheetContext,
      () => reviewsRepository.postReview(
        widget.storyId,
        rating: rating,
        body: body,
        token: token,
      ),
    );
  }

  Future<void> _submitComment(BuildContext sheetContext, String body) async {
    final token = _token;
    if (token == null) {
      AppSnackbar.warning(context, 'Sign in to comment.');
      return;
    }
    await _post(
      sheetContext,
      () => reviewsRepository.postComment(
        widget.storyId,
        body: body,
        token: token,
      ),
    );
  }

  /// Closes the review sheet and nothing else. `context.pop()` from the page
  /// closes whatever is on top — so a second Submit tap, or a sheet the
  /// reader had already dismissed while the post was in flight, used to pop
  /// the novel page itself and drop the reader on Home.
  void _closeSheet(BuildContext sheetContext) {
    if (sheetContext.mounted &&
        (ModalRoute.of(sheetContext)?.isCurrent ?? false)) {
      Navigator.of(sheetContext).pop();
    }
  }

  Future<void> _post(
    BuildContext sheetContext,
    Future<ReviewPostResult> Function() send,
  ) async {
    try {
      final result = await send();
      if (!mounted) return;
      if (sheetContext.mounted) _closeSheet(sheetContext);
      AppSnackbar.success(context, result.message);
      _apply(result);
    } on ApiException catch (e) {
      // Close the sheet first — a snackbar raised under it would be hidden.
      if (!mounted) return;
      if (sheetContext.mounted) _closeSheet(sheetContext);
      AppSnackbar.error(context, e.message);
    }
  }

  /// Repaints the Overall Rating panel and the list straight from the
  /// reply — no refetch. Falls back to a reload only if the reply didn't
  /// carry what's needed.
  void _apply(ReviewPostResult result) {
    final item = result.item;
    final summary = result.summary;
    if (item == null || (!item.isComment && summary == null)) {
      _load();
      return;
    }
    setState(() {
      if (summary != null) _summary = summary;
      final list = [...?_reviews];
      final i = list.indexWhere((r) => r.kind == item.kind && r.id == item.id);
      if (i >= 0) {
        list[i] = item;
      } else {
        list.insert(0, item);
      }
      _reviews = list;
      if (!item.isComment) _myReview = item;
    });
  }

  Future<void> _delete(ReviewApiModel item) async {
    final token = _token;
    if (token == null) return;
    setState(() => _deleting = true);
    try {
      if (item.isComment) {
        await reviewsRepository.deleteComment(item.id, token);
      } else {
        // Removes only the rating — this reader's comments stay listed.
        await reviewsRepository.delete(widget.storyId, token);
      }
      if (!mounted) return;
      AppSnackbar.success(
        context,
        item.isComment ? 'Comment removed.' : 'Review removed.',
      );
      await _load();
    } on ApiException catch (e) {
      if (mounted) AppSnackbar.error(context, e.message);
    } finally {
      if (mounted) setState(() => _deleting = false);
    }
  }

  void _openWrite() {
    if (_token == null) {
      AppSnackbar.warning(context, 'Sign in to write a review.');
      return;
    }
    if (_myReview == null) {
      _showReviewModal(initialRating: 0, initialBody: '');
    } else {
      _showReviewModal(initialRating: 0, initialBody: '', isComment: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(padding: EdgeInsetsGeometry.all(16), child: _buildBody());
  }

  Widget _buildBody() {
    if (_error != null) {
      return ErrorState(message: _error!, onRetry: () => _load(), height: 300);
    }
    if (_reviews == null || _summary == null) {
      return const LoadingState(height: 300);
    }
    final summary = _summary!;
    return SingleChildScrollView(
      child: Column(
        spacing: 12,
        children: [
          // STATS
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              border: Border.all(
                width: 1,
                color: Color.fromRGBO(181, 77, 232, 0.1),
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              spacing: 8,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 4,
                  children: [
                    Text('Overall Rating', style: whiteF12TS),
                    Text(
                      summary.average > 0
                          ? summary.average.toStringAsFixed(1)
                          : '0.0',
                      style: TextStyle(color: Colors.white, fontSize: 26),
                    ),
                    Row(
                      spacing: 4,
                      children: [
                        ...List.generate(summary.average.round(), (index) {
                          return ShaderMask(
                            shaderCallback: (bounds) {
                              return defaultGradientTTB.createShader(bounds);
                            },
                            child: Icon(
                              Remix.star_fill,
                              size: 12,
                              color: Colors.white,
                            ),
                          );
                        }),
                        ...List.generate(5 - summary.average.round(), (index) {
                          return Icon(
                            Remix.star_fill,
                            size: 12,
                            color: Color(0xFF332B42),
                          );
                        }),
                      ],
                    ),
                    Text('${summary.total} reviews', style: whiteF12TS),
                  ],
                ),
                SizedBox(
                  height: 90,
                  child: VerticalDivider(
                    color: Color.fromRGBO(157, 138, 197, 0.2),
                  ),
                ),
                Expanded(
                  child: Column(
                    spacing: 8,
                    children: [5, 4, 3, 2, 1].map((star) {
                      final count = summary.forStar(star);
                      final progress = summary.total == 0
                          ? 0.0
                          : count / summary.total;
                      return _RatingBar(
                        rate: star,
                        progress: progress,
                        total: '$count',
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),

          // WRITE
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              GestureDetector(
                onTap: _openWrite,
                child: Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    gradient: defaultGradientTTB,
                  ),
                  child: Row(
                    spacing: 8,
                    children: [
                      Icon(Remix.pencil_line, size: 16, color: Colors.white),
                      Text(
                        _myReview == null ? 'Write a Review' : 'Add a Comment',
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // LIST OF REVIEWS
          if (_reviews!.isEmpty)
            const NoStoryReview()
          else
            Column(
              spacing: 16,
              children: [
                // Server order is final (own items first, then newest) — no
                // client-side re-sort.
                ..._reviews!.map((review) {
                  return StoryReviewItem(
                    key: ValueKey('${review.kind}-${review.id}'),
                    review: review,
                    onEdit: review.isMine && !review.isComment
                        ? () => _showReviewModal(
                            initialRating: review.rating,
                            initialBody: review.body,
                          )
                        : null,
                    onDelete: review.isMine && !_deleting
                        ? () => _delete(review)
                        : null,
                  );
                }),
                if (_hasMore)
                  TextButton(
                    onPressed: _loadingMore
                        ? null
                        : () => _load(loadMore: true),
                    child: Text(
                      _loadingMore ? 'Loading…' : 'Load more',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }

  Future<dynamic> _showReviewModal({
    required int initialRating,
    required String initialBody,
    bool isComment = false,
  }) {
    final controller = TextEditingController(text: initialBody);
    var rating = initialRating;
    // Held by the sheet itself: the page's own setState never rebuilds this
    // route, so a page-level flag left Submit live for a second tap.
    var sending = false;
    return showModalBottomSheet(
      barrierColor: Color.fromRGBO(255, 255, 255, 0.1),
      isScrollControlled: true,
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            // The sheet's route sits outside the page's own Scaffold, so
            // nothing pushes it up for the keyboard unless this padding does
            // it explicitly — without it, the review text field ends up
            // hidden behind the keyboard instead of scrolled into view.
            final keyboardInset = MediaQuery.of(context).viewInsets.bottom;
            return Padding(
              padding: EdgeInsets.only(bottom: keyboardInset),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight:
                      MediaQuery.of(context).size.height * 0.9 - keyboardInset,
                ),
                child: Container(
                  padding: EdgeInsets.all(16),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Color(0xff0E0318),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      spacing: 16,
                      children: [
                        // DRAGGER
                        Container(
                          width: 100,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Color.fromRGBO(195, 132, 255, 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),

                        // HEADER
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              isComment ? 'Add a Comment' : 'Write a Review',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                            GestureDetector(
                              onTap: () => _closeSheet(context),
                              child: Icon(
                                Remix.close_large_line,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                          ],
                        ),

                        Divider(
                          thickness: 0.5,
                          color: Color.fromRGBO(195, 132, 255, 0.1),
                        ),

                        // YOUR RATING — only on the reader's first post
                        if (!isComment) ...[
                          Column(
                            spacing: 8,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Your Rating',
                                style: TextStyle(
                                  color: Color(0xffDFBDFF),
                                  fontSize: 12,
                                ),
                              ),
                              Row(
                                spacing: 8,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    spacing: 16,
                                    children: [
                                      ...List.generate(5, (index) {
                                        final starIndex = index + 1;
                                        return GestureDetector(
                                          onTap: () {
                                            setSheetState(
                                              () => rating = starIndex,
                                            );
                                          },
                                          child: ShaderMask(
                                            shaderCallback: (bounds) {
                                              return defaultGradientTTB
                                                  .createShader(bounds);
                                            },
                                            child: Icon(
                                              starIndex <= rating
                                                  ? Remix.star_fill
                                                  : Remix.star_line,
                                              size: 24,
                                              color: Colors.white,
                                            ),
                                          ),
                                        );
                                      }),
                                    ],
                                  ),
                                  Text(
                                    '$rating / 5',
                                    style: defaultTextStyle14,
                                  ),
                                ],
                              ),
                              Row(
                                spacing: 8,
                                children: [
                                  Icon(
                                    Remix.information_line,
                                    size: 16,
                                    color: Color(0xff9110DE),
                                  ),
                                  Expanded(
                                    child: Text(
                                      'Tap a star to rate',
                                      style: TextStyle(
                                        color: Color(primaryTextCOLR),
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),

                          Divider(
                            thickness: 0.5,
                            color: Color.fromRGBO(195, 132, 255, 0.1),
                          ),
                        ],

                        // YOUR REVIEW / COMMENT
                        Column(
                          spacing: 12,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isComment ? 'Your Comment' : 'Your Review',
                              style: TextStyle(
                                color: Color(0xffDFBDFF),
                                fontSize: 12,
                              ),
                            ),
                            CustomTextField(
                              controller: controller,
                              placeholder:
                                  'Share your thoughts about this book...',
                              maxLines: 3,
                              maxLength: 2000,
                              hideCounter: false,
                              borderColor: Color.fromRGBO(181, 77, 232, 0.15),
                              hideText: false,
                              hasPrefixIcon: false,
                              hasSuffixIcon: false,
                              onSubmitted: () {},
                              suffixAction: () {},
                              onChange: (value) {},
                            ),
                            Row(
                              spacing: 8,
                              children: [
                                Icon(
                                  Remix.information_line,
                                  size: 16,
                                  color: Color(0xff9110DE),
                                ),
                                Expanded(
                                  child: Text(
                                    'Be respectful and helpful (Reviews that are offensive or spammy may be removed)',
                                    style: TextStyle(
                                      color: Color(primaryTextCOLR),
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),

                        Divider(
                          thickness: 0.5,
                          color: Color.fromRGBO(195, 132, 255, 0.1),
                        ),

                        // ACTIONS
                        Row(
                          spacing: 16,
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () => _closeSheet(context),
                                child: Container(
                                  padding: EdgeInsets.symmetric(vertical: 8),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      width: 0.5,
                                      color: Color.fromRGBO(195, 132, 255, 0.5),
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    spacing: 8,
                                    children: [
                                      Text(
                                        'Cancel',
                                        style: TextStyle(
                                          color: Color.fromRGBO(
                                            195,
                                            132,
                                            255,
                                            0.5,
                                          ),
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: GestureDetector(
                                onTap:
                                    sending || (!isComment && rating == 0)
                                    ? null
                                    : () async {
                                        final body = controller.text.trim();
                                        // Nothing to send yet; a warning
                                        // snackbar would sit under the modal.
                                        if (isComment && body.isEmpty) return;
                                        setSheetState(() => sending = true);
                                        if (isComment) {
                                          await _submitComment(context, body);
                                        } else {
                                          await _submitReview(
                                            context,
                                            rating,
                                            body,
                                          );
                                        }
                                        if (context.mounted) {
                                          setSheetState(() => sending = false);
                                        }
                                      },
                                child: Container(
                                  padding: EdgeInsets.symmetric(vertical: 8),
                                  decoration: BoxDecoration(
                                    gradient: defaultGradientTTB,
                                    border: Border.all(
                                      width: 0.5,
                                      color: Colors.transparent,
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    spacing: 8,
                                    children: [
                                      Text(
                                        sending ? 'Saving…' : 'Submit',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _RatingBar extends StatelessWidget {
  const _RatingBar({
    required this.rate,
    required this.progress,
    required this.total,
  });

  final int rate;
  final double progress;
  final String total;

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 8,
      children: [
        Row(
          spacing: 8,
          children: [
            Text(rate.toString(), style: whiteF10TS),
            Icon(Remix.star_fill, color: Colors.white, size: 10),
          ],
        ),
        Expanded(
          child: SizedBox(
            height: 5,
            child: ShaderMask(
              shaderCallback: (bounds) {
                return const LinearGradient(
                  colors: [
                    Color(0xff8842FF),
                    Color.fromRGBO(255, 255, 255, 0.5),
                  ],
                ).createShader(bounds);
              },
              child: LinearProgressIndicator(
                borderRadius: BorderRadius.circular(5),
                value: progress,
                backgroundColor: Color.fromRGBO(217, 217, 217, 0.1),
                valueColor: AlwaysStoppedAnimation(Colors.white),
              ),
            ),
          ),
        ),
        Text(total, style: whiteF10TS),
      ],
    );
  }
}
