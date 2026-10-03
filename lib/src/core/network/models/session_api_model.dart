class SessionApiModel {
  SessionApiModel({
    required this.id,
    required this.ipAddress,
    required this.userAgent,
    required this.createdAt,
    required this.lastSeenAt,
    required this.isCurrent,
  });

  final int id;
  final String ipAddress;
  final String userAgent;
  final String createdAt;
  final String lastSeenAt;
  final bool isCurrent;

  factory SessionApiModel.fromJson(Map<String, dynamic> json) =>
      SessionApiModel(
        id: json['id'] as int,
        ipAddress: json['ip_address'] as String? ?? '',
        userAgent: json['user_agent'] as String? ?? '',
        createdAt: json['created_at'] as String? ?? '',
        lastSeenAt: json['last_seen_at'] as String? ?? '',
        isCurrent: json['is_current'] as bool? ?? false,
      );

  /// True when [userAgent] looks like the mobile app rather than a browser.
  bool get isApp => userAgent.startsWith('StorrycaApp');

  /// A short device label built from the raw user agent string, e.g.
  /// "Pixel 8" for the app, or "Web Browser" for a browser session — the API
  /// gives no separate device-name field.
  String get deviceLabel {
    final match = RegExp(
      r'StorrycaApp/[\d.]+ \(([^;]+);\s*([^)]+)\)',
    ).firstMatch(userAgent);
    if (match != null) return match.group(2)!.trim();
    return 'Web Browser';
  }

  /// "OS • Browser" (or "OS" alone for the app), built the same way since the
  /// API doesn't split these out.
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
}
