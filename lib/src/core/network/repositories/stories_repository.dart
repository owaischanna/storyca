import 'package:storryca/src/core/network/api_client.dart';
import 'package:storryca/src/core/network/mappers.dart';
import 'package:storryca/src/core/network/models/pagination.dart';
import 'package:storryca/src/core/network/models/story_api_model.dart';
import 'package:storryca/src/features/discover/types/story_item.typres.dart';

class StoriesRepository {
  StoriesRepository(this._client);

  final ApiClient _client;

  Future<Paged<StoryItemTypes>> catalog({
    String? q,
    String? genre,
    String? state,
    String? sort,
    String? audience,
    String? contentRating,
    String? period,
    int? authorId,
    int page = 1,
    int limit = 20,
    // Home feed only — keeps muted authors out of what the app pushes at the
    // reader. Needs [token] so the server knows whose mutes to apply.
    bool hideMuted = false,
    String? token,
  }) async {
    final data = await _client.get(
      '/stories/catalog',
      // Always as the reader: the server hides 18+ books from anyone it
      // can't identify as an adult.
      token: token ?? await _client.readerToken(),
      query: {
        if (hideMuted) 'hide_muted': 1,
        'q': q,
        'genre': genre,
        'state': state,
        'sort': sort,
        'audience': audience,
        'content_rating': contentRating,
        'period': period,
        'author_id': authorId,
        'page': page,
        'limit': limit,
      },
    ) as Map<String, dynamic>;

    final items = (data['items'] as List? ?? [])
        .map((e) => storyItemFromApi(StoryApiModel.fromJson(e)))
        .toList();
    final pagination = data['pagination'] != null
        ? Pagination.fromJson(data['pagination'] as Map<String, dynamic>)
        : Pagination.empty();
    return Paged(items, pagination);
  }

  /// The full genre list (matches the website's filter chips), not just the
  /// ones with published stories.
  Future<List<String>> genres() async {
    final data = await _client.get('/genres') as List;
    return data.map((e) => (e as Map<String, dynamic>)['name'] as String).toList();
  }

  /// Genre chips with their published-story counts, e.g. `{name, total}`.
  Future<List<Map<String, dynamic>>> genresWithCounts() async {
    final data =
        await _client.get(
              '/stories/genres',
              token: await _client.readerToken(),
            )
            as List;
    return data.cast<Map<String, dynamic>>();
  }

  /// Throws [ApiException] with [ApiException.isNotFound] when the story
  /// does not exist or is not published.
  Future<StoryApiModel> byId(int id) async {
    final data =
        await _client.get('/stories/$id', token: await _client.readerToken())
            as Map<String, dynamic>;
    return StoryApiModel.fromJson(data);
  }

  /// Call once when a story's screen opens. Counts once per person per day
  /// server-side (by account when [token] is set, otherwise by
  /// [deviceId]) — safe to call every time the screen opens without
  /// checking anything first. Never throws: a failed or not-yet-live (403
  /// until the server update ships) call must not interrupt reading, and
  /// the caller isn't meant to wait on this anyway.
  Future<void> recordView({
    required int storyId,
    required String deviceId,
    String? token,
  }) async {
    try {
      await _client.post(
        '/stories/view',
        token: token,
        body: {'story_id': storyId},
        extraHeaders: {'X-Device-Id': deviceId},
      );
    } on ApiException {
      // Best-effort — see the doc comment above.
    }
  }

  /// Call every time a chapter is actually opened and shown — not when
  /// prefetching. Counts once per person per story ever, so it's safe to
  /// call on every chapter open. Same fire-and-forget contract as
  /// [recordView].
  Future<void> recordRead({
    required int storyId,
    required int chapterId,
    required String deviceId,
    String? token,
  }) async {
    try {
      await _client.post(
        '/stories/read',
        token: token,
        body: {'story_id': storyId, 'chapter_id': chapterId},
        extraHeaders: {'X-Device-Id': deviceId},
      );
    } on ApiException {
      // Best-effort — see the doc comment above.
    }
  }

  /// For the "New Story" language dropdown.
  Future<List<String>> languages() async {
    final data = await _client.get('/languages') as List;
    return data.map((e) => (e as Map<String, dynamic>)['name'] as String).toList();
  }

  /// For the "New Story" region dropdown.
  Future<List<String>> regions() async {
    final data = await _client.get('/regions') as List;
    return data.map((e) => (e as Map<String, dynamic>)['name'] as String).toList();
  }

  /// The signed-in author's own stories (drafts and "In Review" included).
  /// The API can return other authors' rows if the server-side login
  /// session has quietly expired (see [createOrUpdateStory]), so this
  /// filters to [authorId] itself rather than trusting the response as-is.
  Future<List<StoryApiModel>> myStories({
    required int authorId,
    required String token,
    String? status,
  }) async {
    final data =
        await _client.get(
              '/stories',
              query: {'status': status},
              token: token,
            )
            as List;
    return data
        .map((e) => StoryApiModel.fromJson(e as Map<String, dynamic>))
        .where((story) => story.authorId == authorId)
        .toList();
  }

  /// [state] is `ongoing` or `completed`. Completing needs 20 published
  /// chapters — a 422 carries the server's message saying how many it has.
  /// Returns the state as the server spells it ("Completed" / "Ongoing").
  Future<String> setStoryState(int storyId, String state, String token) async {
    final data =
        await _client.post(
              '/stories/state',
              body: {'story_id': storyId, 'state': state},
              token: token,
            )
            as Map<String, dynamic>;
    return data['state'] as String? ?? '';
  }

  /// Only a Draft can be deleted by its author; anything submitted or live
  /// answers 403 with a message saying to ask an admin.
  Future<void> deleteStory(int storyId, String token) async {
    await _client.delete('/stories', query: {'id': storyId}, token: token);
  }

  /// Creates a story (omit [storyId]) or edits one (pass it). [status] is
  /// `draft` or `published` — `published` from an author always lands as
  /// "In Review", never live. [coverPath] is optional when editing (leaving
  /// it out keeps the current cover) but required to submit a new story.
  ///
  /// This endpoint also needs the login session cookie, not just the Bearer
  /// token, and that session can quietly expire after ~24 minutes of
  /// inactivity even though the token itself is still valid — the server
  /// then answers 401 with "User session is required to create a story."
  /// rather than the usual 403. Surface that specific message plainly rather
  /// than the generic error copy, since simply signing out and back in
  /// resolves it.
  Future<StoryDraftResult> createOrUpdateStory({
    int? storyId,
    required String title,
    required String status,
    String? genre,
    String? summary,
    String? contentRating,
    String? tags,
    String? language,
    String? region,
    String? audience,
    String? coverPath,
    // The novel trailer: [trailerPath] uploads a new one (replacing any
    // existing), [removeTrailer] deletes it, neither leaves it alone.
    String? trailerPath,
    bool removeTrailer = false,
    required String token,
  }) async {
    final fields = <String, String>{
      'title': title,
      'status': status,
      if (storyId != null) 'story_id': storyId.toString(),
      if (genre != null) 'genre': genre,
      if (summary != null) 'summary': summary,
      if (contentRating != null) 'content_rating': contentRating,
      if (tags != null) 'tags': tags,
      if (language != null) 'language': language,
      if (region != null) 'region': region,
      if (audience != null) 'audience': audience,
      if (removeTrailer && trailerPath == null) 'remove_trailer': '1',
    };
    try {
      final data =
          await _client.postFile(
                '/stories',
                fields: fields,
                fileField: coverPath == null ? null : 'cover',
                filePath: coverPath,
                extraFiles: {'trailer': ?trailerPath},
                token: token,
                // A trailer is up to 50MB on a mobile connection: give it
                // time, and never quietly upload it a second time.
                timeout: trailerPath == null
                    ? null
                    : const Duration(minutes: 15),
                retry: trailerPath == null,
              )
              as Map<String, dynamic>;
      return StoryDraftResult.fromJson(data);
    } on ApiException catch (e) {
      if (e.statusCode == 401) {
        throw ApiException(
          'Your writing session timed out. Please sign out and sign back '
          'in, then try again.',
          statusCode: 401,
        );
      }
      rethrow;
    }
  }
}

class StoryDraftResult {
  StoryDraftResult({
    required this.storyId,
    required this.status,
    required this.cover,
    this.trailer,
  });

  final int storyId;
  final String status;
  final String? cover;
  final StoryTrailer? trailer;

  factory StoryDraftResult.fromJson(Map<String, dynamic> json) => StoryDraftResult(
    storyId: json['story_id'] as int,
    status: json['status'] as String? ?? '',
    cover: json['cover'] as String?,
    trailer: StoryTrailer.maybeFromJson(json['trailer']),
  );
}
