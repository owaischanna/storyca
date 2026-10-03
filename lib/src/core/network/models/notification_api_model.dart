class NotificationApiModel {
  NotificationApiModel({
    required this.id,
    required this.category,
    required this.title,
    required this.message,
    required this.isRead,
    required this.createdAt,
    required this.storyId,
  });

  final int id;
  final String category;
  final String title;
  final String message;
  final bool isRead;
  final String createdAt;

  /// From `meta.story_id`, when this notification is about a story — used to
  /// open that story on tap.
  final int? storyId;

  factory NotificationApiModel.fromJson(Map<String, dynamic> json) {
    final meta = json['meta'] as Map<String, dynamic>?;
    return NotificationApiModel(
      id: json['id'] as int,
      category: json['category'] as String? ?? '',
      title: json['title'] as String? ?? '',
      message: json['message'] as String? ?? '',
      isRead: json['is_read'] as bool? ?? false,
      createdAt: json['created_at'] as String? ?? '',
      storyId: meta?['story_id'] as int?,
    );
  }
}
