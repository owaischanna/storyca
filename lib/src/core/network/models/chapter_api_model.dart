class ChapterApiModel {
  ChapterApiModel({
    required this.id,
    required this.storyId,
    required this.title,
    required this.body,
    required this.status,
    required this.wordCount,
    required this.orderIndex,
    required this.updatedAt,
    required this.locked,
  });

  final int id;
  final int storyId;
  final String title;
  final String body;
  final String status;
  final int wordCount;
  final int orderIndex;
  final String updatedAt;

  /// True when the reader hasn't unlocked this chapter's book yet — the
  /// server sends an empty [body] alongside it, so the chapter list should
  /// draw a lock icon instead of trying to show any text.
  final bool locked;

  factory ChapterApiModel.fromJson(Map<String, dynamic> json) =>
      ChapterApiModel(
        id: json['id'] as int,
        storyId: json['story_id'] as int,
        title: json['title'] as String? ?? '',
        body: json['body'] as String? ?? '',
        status: json['status'] as String? ?? '',
        wordCount: json['word_count'] as int? ?? 0,
        orderIndex: json['order_index'] as int? ?? 0,
        updatedAt: json['updated_at'] as String? ?? '',
        locked: json['locked'] as bool? ?? false,
      );
}
