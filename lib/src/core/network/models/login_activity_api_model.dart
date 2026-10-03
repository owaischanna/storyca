class LoginActivityApiModel {
  LoginActivityApiModel({
    required this.id,
    required this.status,
    required this.ipAddress,
    required this.location,
    required this.userAgent,
    required this.note,
    required this.createdAt,
    required this.isCurrent,
  });

  final int id;
  final String status;
  final String ipAddress;
  final String? location;
  final String userAgent;
  final String note;
  final String createdAt;
  final bool isCurrent;

  bool get isSuccess => status == 'success';

  bool get isApp => userAgent.startsWith('StorrycaApp');

  /// A short device label built from the raw user agent string — the API
  /// doesn't give a separate device-name field.
  String get deviceLabel {
    final match = RegExp(
      r'StorrycaApp/[\d.]+ \(([^;]+);\s*([^)]+)\)',
    ).firstMatch(userAgent);
    if (match != null) return match.group(2)!.trim();
    return 'Web Browser';
  }

  /// "OS • Browser" (or just the OS for the app).
  String get platformLabel {
    final match = RegExp(
      r'StorrycaApp/[\d.]+ \(([^;]+);\s*([^)]+)\)',
    ).firstMatch(userAgent);
    if (match != null) return match.group(1)!.trim();

    String os = 'Unknown';
    if (userAgent.contains('Windows')) {
      os = 'Windows';
    } else if (userAgent.contains('Mac OS')) {
      os = 'macOS';
    } else if (userAgent.contains('Android')) {
      os = 'Android';
    } else if (userAgent.contains('iPhone') || userAgent.contains('iPad')) {
      os = 'iOS';
    } else if (userAgent.contains('Linux')) {
      os = 'Linux';
    }

    String browser = 'Browser';
    if (userAgent.contains('Edg/')) {
      browser = 'Edge';
    } else if (userAgent.contains('Chrome/')) {
      browser = 'Chrome';
    } else if (userAgent.contains('Firefox/')) {
      browser = 'Firefox';
    } else if (userAgent.contains('Safari/')) {
      browser = 'Safari';
    }
    return '$os • $browser';
  }

  /// Human-readable wording for [note], per the documented values.
  String get description => switch (note) {
    'login_success' => 'Signed in with email and password',
    'google_login_success' => 'Signed in with Google',
    'two_factor_verified' => 'Signed in, two-step code accepted',
    'login_unverified_email' => 'Signed in, email not verified yet',
    'invalid_credentials' => 'Wrong password',
    'two_factor_verification_failed' => 'Wrong two-step code',
    'blocked_password_login_attempt' => 'Account is blocked',
    'blocked_google_login_attempt' => 'Account is blocked',
    'blocked_two_factor_login_attempt' => 'Account is blocked',
    _ => isSuccess ? 'Signed in' : 'Sign-in failed',
  };

  factory LoginActivityApiModel.fromJson(Map<String, dynamic> json) =>
      LoginActivityApiModel(
        id: json['id'] as int,
        status: json['status'] as String? ?? '',
        ipAddress: json['ip_address'] as String? ?? '',
        location: json['location'] as String?,
        userAgent: json['user_agent'] as String? ?? '',
        note: json['note'] as String? ?? '',
        createdAt: json['created_at'] as String? ?? '',
        isCurrent: json['is_current'] as bool? ?? false,
      );
}
