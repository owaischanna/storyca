import 'package:storryca/src/core/network/api_client.dart';

/// Narration for one chapter. [audioUrl] is a complete, signed link — hand it
/// to the player exactly as-is, never with headers, never stored: it expires
/// after [expiresIn] seconds (3 hours), so it's fetched fresh each time.
class ChapterAudio {
  ChapterAudio({
    required this.chapterId,
    required this.status,
    required this.ready,
    required this.duration,
    required this.audioUrl,
    required this.expiresIn,
  }) : fetchedAt = DateTime.now();

  final int chapterId;

  /// none / pending / ready / failed — for logs and support. Logic uses
  /// [ready].
  final String status;
  final bool ready;

  /// Ready to display: "43 sec", "12 min", "1 hr 12 min"; empty when none.
  final String duration;
  final String? audioUrl;
  final int expiresIn;
  final DateTime fetchedAt;

  /// True a couple of minutes before the signed link actually dies, so a
  /// fresh one is fetched before handing it to the player.
  bool get urlExpired =>
      DateTime.now().difference(fetchedAt).inSeconds > expiresIn - 120;

  factory ChapterAudio.fromJson(Map<String, dynamic> j) => ChapterAudio(
    chapterId: (j['chapter_id'] as num?)?.toInt() ?? 0,
    status: j['status'] as String? ?? 'none',
    ready: j['ready'] as bool? ?? false,
    duration: j['duration'] as String? ?? '',
    audioUrl: j['audio_url'] as String?,
    expiresIn: (j['url_expires_in'] as num?)?.toInt() ?? 0,
  );
}

class AudioRepository {
  AudioRepository(this._client);

  final ApiClient _client;

  /// Set after a 429 — the month's narration allowance is spent, so the
  /// Listen button stays hidden for the rest of this session.
  bool allowanceUsedUp = false;

  /// Read-only, free: does this chapter have narration? 402 when the book
  /// isn't unlocked.
  Future<ChapterAudio> chapter(int chapterId, String token) async {
    final data =
        await _client.get('/audio/chapter/$chapterId', token: token)
            as Map<String, dynamic>;
    return ChapterAudio.fromJson(data);
  }

  /// Makes the narration — the only call that can cost the client money.
  /// Only ever called from a reader pressing Listen. Takes 10-20 s, so a 90 s
  /// timeout, and never retried automatically: 409 already being made, 429
  /// allowance used up, 503 TTS unreachable.
  Future<ChapterAudio> generate(int chapterId, String token) async {
    final data =
        await _client.post(
              '/audio/chapter/$chapterId',
              token: token,
              timeout: const Duration(seconds: 90),
              retry: false,
            )
            as Map<String, dynamic>;
    return ChapterAudio.fromJson(data);
  }
}
