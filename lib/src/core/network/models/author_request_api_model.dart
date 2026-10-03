class AuthorRequestApiModel {
  AuthorRequestApiModel({
    required this.id,
    required this.status,
    required this.submittedAt,
    required this.reviewNote,
  });

  final int id;
  final String status;
  final String submittedAt;
  final String? reviewNote;

  bool get isPending => status == 'pending';
  bool get isApproved => status == 'approved';
  bool get isDeclined => status == 'declined';

  factory AuthorRequestApiModel.fromJson(Map<String, dynamic> json) =>
      AuthorRequestApiModel(
        id: json['id'] as int,
        status: json['status'] as String? ?? '',
        submittedAt: json['submitted_at'] as String? ?? '',
        reviewNote: json['review_note'] as String?,
      );
}
