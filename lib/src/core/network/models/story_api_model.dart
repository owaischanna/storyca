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
    this.ratingAvg = 0,
    this.contentRating = '',
    this.language = '',
    this.region = '',
    this.audience = '',
    this.trailer,
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

  /// The average star rating, 0–5. [ratings] is the NUMBER of reviews —
  /// drawing stars from it crashed the book page once a book had more than
  /// five reviews (5 - 10 stars = a negative count).
  final double ratingAvg;

  /// The rest of the story form, as the server spells it — used to prefill
  /// "Edit Story".
  final String contentRating;
  final String language;
  final String region;
  final String audience;

  /// The novel trailer; null means the novel has none.
  final StoryTrailer? trailer;

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
    // Sent as a number by the catalogue and as text ("4.20") by /stories/{id}.
    ratingAvg: (double.tryParse('${json['rating_avg'] ?? ''}') ?? 0).clamp(0, 5),
    contentRating: json['content_rating'] as String? ?? '',
    language: json['language'] as String? ?? '',
    region: json['region'] as String? ?? '',
    audience: json['audience'] as String? ?? '',
    trailer:
        StoryTrailer.maybeFromJson(json['trailer']) ??
        StoryTrailer.fromListRow(json),
  );
}

/// A novel's short video. [url] is public and absolute — hand it straight
/// to the player, no token.
class StoryTrailer {
  StoryTrailer({
    required this.url,
    required this.mime,
    required this.durationLabel,
    required this.width,
    required this.height,
  });

  final String url;
  final String mime;

  /// Already formatted by the server ("0:32") — print as-is.
  final String durationLabel;
  final int width;
  final int height;

  /// Always 16:9 landscape; falls back to that if the sizes are missing.
  double get aspectRatio =>
      width > 0 && height > 0 ? width / height : 16 / 9;

  /// Only an object counts as a trailer; null (or anything else) means none.
  static StoryTrailer? maybeFromJson(Object? json) {
    if (json is! Map<String, dynamic>) return null;
    final url = json['url'] as String? ?? '';
    if (url.isEmpty) return null;
    return StoryTrailer(
      url: url,
      mime: json['mime'] as String? ?? '',
      durationLabel: json['duration_label'] as String? ?? '',
      width: (json['width'] as num?)?.toInt() ?? 0,
      height: (json['height'] as num?)?.toInt() ?? 0,
    );
  }

  /// The author's own list (`GET /stories`) sends the trailer as a bare
  /// file name with `trailer_width` / `trailer_height` beside it; the file
  /// lives at the same public path the story object's `url` points to.
  static StoryTrailer? fromListRow(Map<String, dynamic> row) {
    final file = row['trailer'];
    if (file is! String || file.isEmpty) return null;
    return StoryTrailer(
      url: 'https://storryca.com/trailer/$file',
      mime: '',
      durationLabel: '',
      width: (row['trailer_width'] as num?)?.toInt() ?? 0,
      height: (row['trailer_height'] as num?)?.toInt() ?? 0,
    );
  }
}
