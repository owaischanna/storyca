class SecurityAlertApiModel {
  SecurityAlertApiModel({
    required this.id,
    required this.alertType,
    required this.title,
    required this.message,
    required this.severity,
    required this.isRead,
    required this.createdAt,
  });

  final int id;
  final String alertType;
  final String title;
  final String message;
  final String severity;
  final bool isRead;
  final String createdAt;

  factory SecurityAlertApiModel.fromJson(Map<String, dynamic> json) =>
      SecurityAlertApiModel(
        id: json['id'] as int,
        alertType: json['alert_type'] as String? ?? '',
        title: json['title'] as String? ?? '',
        message: json['message'] as String? ?? '',
        severity: json['severity'] as String? ?? 'info',
        isRead: (json['status'] as String? ?? 'new') != 'new',
        createdAt: json['created_at'] as String? ?? '',
      );
}
