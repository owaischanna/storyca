class StoryItemTypes {
  final String title;
  final String image;
  final int id;
  final double reads;
  final int comments;
  final int rating;
  final int ratingCount;
  final String category;
  final int currentChapter;
  final int totalChapter;
  final double progress;
  final bool isSaved;
  final String author;
  final String description;
  final String likes;
  final String views;
  final String status;

  /// The chapter to resume at on the Library screen's "Reading" tab, from
  /// `/library/reading`'s `progress_chapter_id`. Null for lists that don't
  /// carry progress (e.g. the catalogue, Saved).
  final int? progressChapterId;

  /// Reads inside the request's time window (`period_reads`), e.g. Trending's
  /// 3 days. Only the Ranking screen's Today / Week / Month tabs show this;
  /// every other card shows the lifetime [reads].
  final double? periodReads;

  StoryItemTypes({
    required this.title,
    required this.image,
    required this.id,
    required this.reads,
    required this.comments,
    required this.rating,
    required this.ratingCount,
    required this.category,
    required this.currentChapter,
    required this.totalChapter,
    required this.progress,
    required this.isSaved,
    required this.author,
    required this.description,
    required this.likes,
    required this.views,
    required this.status,
    this.progressChapterId,
    this.periodReads,
  });
}
