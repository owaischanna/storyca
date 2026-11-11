import 'package:storryca/src/core/network/api_client.dart';
import 'package:storryca/src/core/network/models/pagination.dart';
import 'package:storryca/src/core/network/models/review_api_model.dart';

class ReviewsPage {
  ReviewsPage(this.items, this.pagination, this.summary);

  final List<ReviewApiModel> items;
  final Pagination pagination;
  final RatingSummaryApiModel summary;
}

/// A saved review or comment. [summary] and [item] come straight from the
/// reply's `data`; either is null when the reply didn't carry it in a shape
/// this app reads, and the caller then reloads the list instead.
class ReviewPostResult {
  ReviewPostResult({required this.message, this.summary, this.item});

  final String message;
  final RatingSummaryApiModel? summary;
  final ReviewApiModel? item;

  factory ReviewPostResult.fromEnvelope(
    Map<String, dynamic> res, {
    required String kind,
    required String fallbackMessage,
  }) {
    final data = res['data'];
    RatingSummaryApiModel? summary;
    ReviewApiModel? item;
    if (data is Map<String, dynamic>) {
      try {
        final s = data['summary'];
        if (s is Map<String, dynamic>) {
          summary = RatingSummaryApiModel.fromJson(s);
        }
      } catch (_) {}
      try {
        final r = data[kind];
        if (r is Map<String, dynamic>) {
          // It's the reader's own post, whatever the reply says.
          item = ReviewApiModel.fromJson({
            ...r,
            'kind': r['kind'] ?? kind,
            'is_mine': true,
          });
        }
      } catch (_) {}
    }
    return ReviewPostResult(
      message: res['message'] as String? ?? fallbackMessage,
      summary: summary,
      item: item,
    );
  }
}

class ReviewsRepository {
  ReviewsRepository(this._client);

  final ApiClient _client;

  Future<ReviewsPage> list(
    int storyId, {
    int page = 1,
    int limit = 20,
    String? token,
  }) async {
    final data =
        await _client.get(
              '/reviews',
              query: {'story_id': storyId, 'page': page, 'limit': limit},
              token: token,
            )
            as Map<String, dynamic>;

    final items = (data['items'] as List? ?? [])
        .map((e) => ReviewApiModel.fromJson(e as Map<String, dynamic>))
        .toList();
    final pagination = data['pagination'] != null
        ? Pagination.fromJson(data['pagination'] as Map<String, dynamic>)
        : Pagination.empty();
    final summary = RatingSummaryApiModel.fromJson(
      data['summary'] as Map<String, dynamic>,
    );
    return ReviewsPage(items, pagination, summary);
  }

  Future<RatingSummaryApiModel> summary(int storyId) async {
    final data =
        await _client.get('/reviews/summary', query: {'story_id': storyId})
            as Map<String, dynamic>;
    return RatingSummaryApiModel.fromJson(data);
  }

  Future<ReviewApiModel?> mine(int storyId, String token) async {
    final data =
        await _client.get(
              '/reviews/mine',
              query: {'story_id': storyId},
              token: token,
            )
            as Map<String, dynamic>;
    final review = data['review'] as Map<String, dynamic>?;
    return review == null ? null : ReviewApiModel.fromJson(review);
  }

  /// A reader's first post on a story must carry [rating] (1–5) and becomes
  /// their review; sending a rating again edits that review. The reply's
  /// `data.summary` and `data.review` repaint the panel and list directly.
  Future<ReviewPostResult> postReview(
    int storyId, {
    required int rating,
    String body = '',
    required String token,
  }) async {
    final res =
        await _client.post(
              '/reviews',
              body: {'story_id': storyId, 'rating': rating, 'body': body},
              token: token,
              includeEnvelope: true,
            )
            as Map<String, dynamic>;
    return ReviewPostResult.fromEnvelope(
      res,
      kind: 'review',
      fallbackMessage: 'Review saved.',
    );
  }

  /// Any post after the reader's review — no rating. Refused with 422
  /// "Rate the story first…" if they haven't reviewed yet.
  Future<ReviewPostResult> postComment(
    int storyId, {
    required String body,
    required String token,
  }) async {
    final res =
        await _client.post(
              '/reviews/comment',
              body: {'story_id': storyId, 'body': body},
              token: token,
              includeEnvelope: true,
            )
            as Map<String, dynamic>;
    return ReviewPostResult.fromEnvelope(
      res,
      kind: 'comment',
      fallbackMessage: 'Comment posted.',
    );
  }

  /// Removes only the rating; the reader's comments stay. Repaint the stars
  /// from the returned summary.
  Future<RatingSummaryApiModel> delete(int storyId, String token) async {
    final data =
        await _client.delete(
              '/reviews',
              body: {'story_id': storyId},
              token: token,
            )
            as Map<String, dynamic>;
    return RatingSummaryApiModel.fromJson(data['summary'] as Map<String, dynamic>);
  }

  Future<void> deleteComment(int commentId, String token) async {
    await _client.delete(
      '/reviews/comment',
      body: {'comment_id': commentId},
      token: token,
    );
  }
}
