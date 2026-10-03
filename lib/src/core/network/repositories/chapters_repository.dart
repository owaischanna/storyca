import 'package:storryca/src/core/network/api_client.dart';
import 'package:storryca/src/core/network/models/chapter_api_model.dart';

class ChaptersRepository {
  ChaptersRepository(this._client);

  final ApiClient _client;

  /// Public callers (the reader) omit [token] and only ever see published
  /// chapters of a published story. The story's own author passes their
  /// token to also see their drafts, in reading order.
  Future<List<ChapterApiModel>> byStoryId(int storyId, {String? token}) async {
    final data = await _client.get(
      '/chapters',
      query: {'story_id': storyId},
      token: token,
    );
    final items = data is Map<String, dynamic> ? data['items'] as List? : data as List?;
    return (items ?? []).map((e) => ChapterApiModel.fromJson(e)).toList()
      ..sort((a, b) => a.orderIndex.compareTo(b.orderIndex));
  }

  Future<ChapterApiModel?> byId(int chapterId, {String? token}) async {
    final data = await _client.get(
      '/chapters',
      query: {'id': chapterId},
      token: token,
    );
    if (data is Map<String, dynamic> && data.containsKey('id')) {
      return ChapterApiModel.fromJson(data);
    }
    final items = data is Map<String, dynamic> ? data['items'] as List? : data as List?;
    if (items == null || items.isEmpty) return null;
    return ChapterApiModel.fromJson(items.first);
  }

  /// Creates a chapter (omit [chapterId]) or edits one (pass it). Always
  /// send [title]/[body]/[status] together on an edit — the endpoint saves
  /// exactly what's sent, so leaving `status` out silently drops a published
  /// chapter back to draft.
  ///
  /// Returns only `{id, word_count, order_index}` — not the full chapter —
  /// so this doesn't reuse [ChapterApiModel], which requires fields (like
  /// `story_id`) this response doesn't include.
  Future<ChapterSaveResult> createOrUpdateChapter({
    required int storyId,
    int? chapterId,
    required String title,
    required String body,
    required String status,
    int? orderIndex,
    required String token,
  }) async {
    final data =
        await _client.post(
              '/chapters',
              token: token,
              body: {
                'story_id': storyId,
                if (chapterId != null) 'chapter_id': chapterId,
                'title': title,
                'body': body,
                'status': status,
                if (orderIndex != null) 'order_index': orderIndex,
              },
            )
            as Map<String, dynamic>;
    return ChapterSaveResult.fromJson(data);
  }

  Future<void> deleteChapter(int chapterId, String token) async {
    await _client.delete('/chapters', query: {'id': chapterId}, token: token);
  }
}

class ChapterSaveResult {
  ChapterSaveResult({required this.id, required this.wordCount, required this.orderIndex});

  final int id;
  final int wordCount;
  final int orderIndex;

  factory ChapterSaveResult.fromJson(Map<String, dynamic> json) => ChapterSaveResult(
    id: json['id'] as int,
    wordCount: json['word_count'] as int? ?? 0,
    orderIndex: json['order_index'] as int? ?? 0,
  );
}
