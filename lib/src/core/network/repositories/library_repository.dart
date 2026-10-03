import 'package:storryca/src/core/network/api_client.dart';
import 'package:storryca/src/core/network/mappers.dart';
import 'package:storryca/src/core/network/models/story_api_model.dart';
import 'package:storryca/src/features/discover/types/story_item.typres.dart';

class LibraryRepository {
  LibraryRepository(this._client);

  final ApiClient _client;

  /// Bumped after a save/unsave anywhere, so the Library tab (kept alive in
  /// the bottom-nav stack) reloads its shelves instead of going stale.
  final ValueNotifier<int> changed = ValueNotifier(0);

  static const int _pageSize = 20;

  // A shelf of fifty is a handful of requests, a runaway server never more
  // than this.
  static const int _maxPages = 25;

  Future<List<StoryItemTypes>> _list(
    String path,
    String token, {
    bool withProgress = false,
    String? genre,
    String? sort,
  }) async {
    // Pages through with `pagination.has_more` — one call would only ever
    // return the first page of a shelf.
    final items = <dynamic>[];
    for (var page = 1; page <= _maxPages; page++) {
      final data =
          await _client.get(
                path,
                query: {
                  'genre': genre,
                  'sort': sort,
                  'limit': _pageSize,
                  'page': page,
                },
                token: token,
              )
              as Map<String, dynamic>;
      items.addAll(data['items'] as List? ?? const []);
      final pagination = data['pagination'] as Map<String, dynamic>?;
      if (pagination?['has_more'] != true) break;
    }
    return items.map((e) {
      final json = e as Map<String, dynamic>;
      final item = storyItemFromApi(StoryApiModel.fromJson(json));
      if (!withProgress) return item;
      final percent = ((json['progress_percent'] as num?) ?? 0).toDouble();
      final progress = (percent / 100).clamp(0, 1).toDouble();
      return StoryItemTypes(
        id: item.id,
        title: item.title,
        image: item.image,
        reads: item.reads,
        comments: item.comments,
        rating: item.rating,
        ratingCount: item.ratingCount,
        category: item.category,
        currentChapter: (progress * item.totalChapter).round(),
        totalChapter: item.totalChapter,
        progress: progress,
        isSaved: item.isSaved,
        author: item.author,
        description: item.description,
        likes: item.likes,
        views: item.views,
        status: item.status,
        progressChapterId: json['progress_chapter_id'] as int?,
      );
    }).toList();
  }

  Future<List<StoryItemTypes>> reading(String token, {String? genre, String? sort}) =>
      _list('/library/reading', token, withProgress: true, genre: genre, sort: sort);

  Future<List<StoryItemTypes>> saved(String token, {String? genre, String? sort}) =>
      _list('/library/saved', token, genre: genre, sort: sort);

  Future<List<StoryItemTypes>> completed(String token, {String? genre, String? sort}) =>
      _list('/library/completed', token, withProgress: true, genre: genre, sort: sort);

  Future<bool> isSaved(int storyId, String token) async {
    final data =
        await _client.get(
              '/library/saved/check',
              query: {'story_id': storyId},
              token: token,
            )
            as Map<String, dynamic>;
    return data['saved'] as bool? ?? false;
  }

  /// Returns the server's `saved` — repaint from it, not from what was
  /// asked. Saving twice is a 200 with `saved: true`, not an error.
  Future<bool> save(int storyId, String token) async {
    final data =
        await _client.post(
              '/library/saved',
              body: {'story_id': storyId},
              token: token,
            )
            as Map<String, dynamic>;
    changed.value++;
    return data['saved'] as bool? ?? true;
  }

  /// Returns the server's `saved`. Removing twice is a 200 with
  /// `saved: false`, not an error.
  Future<bool> unsave(int storyId, String token) async {
    final data =
        await _client.delete(
              '/library/saved',
              query: {'story_id': storyId},
              token: token,
            )
            as Map<String, dynamic>;
    changed.value++;
    return data['saved'] as bool? ?? false;
  }

  /// Progress for one story, or null if the reader has never opened it.
  /// (The API returns a JSON `null` `data` for that case, which the client's
  /// envelope decoding turns into an empty map — treated as "no progress"
  /// here rather than a zeroed-out [ReadingProgress].)
  Future<ReadingProgress?> progress(int storyId, String token) async {
    final data =
        await _client.get(
              '/library/progress',
              query: {'story_id': storyId},
              token: token,
            )
            as Map<String, dynamic>;
    return data.isEmpty ? null : ReadingProgress.fromJson(data);
  }

  /// Call as the reader scrolls, or when they leave a chapter. [percent] is
  /// clamped 0-100 server-side; reaching 100 marks the story completed and
  /// moves it from /library/reading to /library/completed. Repeated calls
  /// update the same row rather than creating duplicates.
  Future<void> saveProgress({
    required int storyId,
    required int chapterId,
    required int percent,
    required String token,
  }) async {
    await _client.post(
      '/library/progress',
      body: {'story_id': storyId, 'chapter_id': chapterId, 'percent': percent},
      token: token,
    );
  }
}

class ReadingProgress {
  ReadingProgress({
    required this.percent,
    required this.ch