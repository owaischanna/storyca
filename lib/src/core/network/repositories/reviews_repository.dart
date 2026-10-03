import 'package:storryca/src/core/network/api_client.dart';
import 'package:storryca/src/core/network/models/pagination.dart';
import 'package:storryca/src/core/network/models/review_api_model.dart';

class ReviewsPage {
  ReviewsPage(this.items, this.pagination, this.summary);

  final List<ReviewApiModel> items;
  final Pagination pagination;
  final RatingSummaryApiModel summary;
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
  /// their review; sending a rating again edits that review. Returns the
  /// server's message. The response shape differs between a review and a
  /// comment, so callers reload the list rather than reading it.
  Future<String> postReview(
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
    return res['message'] as String? ?? 'Review saved.';
  }

  /// Any post after the reader's review — no rating. Refused with 422
  /// "Rate the story first…" if they haven't reviewed yet.
  Future<String> postComment(
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
    return res['message'] as String? ?? 'Comment posted.';
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
