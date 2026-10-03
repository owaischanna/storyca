class ReviewUserApiModel {
  ReviewUserApiModel({
    required this.id,
    required this.name,
    required this.username,
    required this.image,
    required this.type,
    required this.isAuthor,
  });

  final int id;
  final String name;
  final String username;
  final String? image;
  final String type;
  final bool isAuthor;

  factory ReviewUserApiModel.fromJson(Map<String, dynamic> json) =>
      ReviewUserApiModel(
        id: json['id'] as int,
        name: json['name'] as String? ?? '',
        username: json['username'] as String? ?? '',
        image: json['image'] as String?,
        type: json['type'] as String? ?? 'user',
        isAuthor: json['is_author'] as bool? ?? false,
      );
}

class ReviewApiModel {
  ReviewApiModel({
    required this.id,
    required this.storyId,
    required this.kind,
    required this.rating,
    required this.body,
    required this.createdAt,
    required this.updatedAt,
    required this.user,
    required this.isMine,
  });

  final int id;
  final int storyId;

  /// `review` (carries stars) or `comment` (rating always 0 — draw no star
  /// row). Ids are only unique within a kind, so key widgets on kind + id.
  final String kind;
  bool get isComment => kind == 'comment';
  final int rating;
  final String body;
  final String createdAt;
  final String updatedAt;
  final ReviewUserApiModel user;
  final bool isMine;

  factory ReviewApiModel.fromJson(Map<String, dynamic> json) => ReviewApiModel(
    id: json['id'] as int,
    storyId: json['story_id'] as int,
    kind: json['kind'] as String? ?? 'review',
    rating: json['rating'] as int? ?? 0,
    body: json['body'] as String? ?? '',
    createdAt: json['created_at'] as String? ?? '',
    updatedAt: json['updated_at'] as String? ?? '',
    user: ReviewUserApiModel.fromJson(json['user'] as Map<String, dynamic>),
    isMine: json['is_mine'] as bool? ?? false,
  );
}

class RatingSummaryApiModel {
  RatingSummaryApiModel({
    required this.storyId,
    required this.total,
    required this.average,
    required this.breakdown,
  });

  final int storyId;
  final int total;
  final double average;

  /// Keyed by star as a string, `"5"` down to `"1"`.
  final Map<String, int> breakdown;

  int forStar(int star) => breakdown['$star'] ?? 0;

  factory RatingSummaryApiModel.fromJson(Map<String, dynamic> json) =>
      RatingSummaryApiModel(
        storyId: json['story_id'] as int,
        total: json['total'] as int? ?? 0,
        average: (json['average'] as num?)?.toDouble() ?? 0,
        breakdown: (json['breakdown'] as Map<String, dynamic>? ?? const {})
            .map((key, value) => MapEntry(key, value as int? ?? 0)),
      );
}
