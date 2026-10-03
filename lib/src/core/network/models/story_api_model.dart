class StoryApiModel {
  StoryApiModel({
    required this.id,
    required this.title,
    required this.genre,
    required this.summary,
    required this.tags,
    required this.status,
    required this.state,
    required this.views,
    required this.reads,
    required this.likes,
    required this.ratings,
    required this.chapters,
    required this.authorId,
    required this.authorName,
    required this.authorImage,
    required this.cover,
    this.periodReads,
  });

  final int id;
  final String title;
  final String genre;
  final String summary;
  final String tags;
  final String status;
  final String state;
  final num views;
  final num reads;
  final num likes;
  final num ratings;
  final int chapters;
  final int authorId;
  final String authorName;
  final String? authorImage;
  final String? cover;

  /// Only present when the catalogue was queried with `period=`; the read
  /// count for that period rather than lifetime reads.
  final num? periodReads;

  factory StoryApiModel.fromJson(Map<String, dynamic> json) => StoryApiModel(
    id: json['id'] as int,
    title: json['title'] as String? ?? '',
    genre: json['genre'] as String? ?? '',
    summary: json['summary'] as String? ?? '',
    tags: json['tags'] as String? ?? '',
    status: json['status'] as String? ?? '',
    state: json['state'] as String? ?? '',
    views: json['views'] as num? ?? 0,
    reads: json['reads'] as num? ?? 0,
    likes: json['likes'] as num? ?? 0,
    ratings: json['ratings'] as num? ?? 0,
    chapters: json['chapters'] as int? ?? 0,
    authorId: json['author_id'] as int? ?? 0,
    authorName: json['author_name'] as String? ?? 'Storryca',
    authorImage: json['author_image'] as String?,
    cover: json['cover'] as String?,
    periodReads: json['period_reads'] as num?,
  );
}
