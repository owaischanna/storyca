import 'package:storryca/src/core/network/api_client.dart';

class ModerationRepository {
  ModerationRepository(this._client);

  final ApiClient _client;

  Future<bool> isMuted(int userId, String token) async {
    final data =
        await _client.get(
              '/moderation/mute',
              query: {'user_id': userId},
              token: token,
            )
            as Map<String, dynamic>;
    return data['muted'] as bool? ?? false;
  }

  /// Returns the server's `muted` state and message — repaint from these,
  /// not from what was requested. Muting twice (or unmuting something never
  /// muted) is a 200, not an error.
  Future<(bool, String)> setMuted(int userId, bool mute, String token) async {
    final body = mute
        ? await _client.post(
            '/moderation/mute',
            body: {'user_id': userId},
            token: token,
            includeEnvelope: true,
          )
        : await _client.delete(
            '/moderation/mute',
            body: {'user_id': userId},
            token: token,
          );
    // delete() returns only `data`; post with includeEnvelope returns all.
    final map = body as Map<String, dynamic>;
    final data = (map['data'] as Map<String, dynamic>?) ?? map;
    final message =
        map['message'] as String? ??
        (mute
            ? 'Muted. Their new stories will stay out of your feed.'
            : 'Unmuted. Their stories can show in your feed again.');
    return (data['muted'] as bool? ?? mute, message);
  }

  /// `{key: label}` — send the key back as `reason`, show the label.
  Future<Map<String, String>> reasons() async {
    final data =
        await _client.get('/moderation/reasons') as Map<String, dynamic>;
    return (data['reasons'] as Map<String, dynamic>? ?? const {}).map(
      (key, value) => MapEntry(key, value as String),
    );
  }

  /// [targetType] is `user`, `story`, `review` or `comment`. Reporting the
  /// same thing twice updates the open report — both answer 200. Returns the
  /// server's message, written to be shown to the reader.
  Future<String> report({
    required String targetType,
    required int targetId,
    required String reason,
    String? note,
    required String token,
  }) async {
    final body =
        await _client.post(
              '/moderation/report',
              body: {
                'target_type': targetType,
                'target_id': targetId,
                'reason': reason,
                if (note != null && note.isNotEmpty) 'note': note,
              },
              token: token,
              includeEnvelope: true,
            )
            as Map<String, dynamic>;
    return body['message'] as String? ??
        'Thank you. Our team will look at this.';
  }
}
