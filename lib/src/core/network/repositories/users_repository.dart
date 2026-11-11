import 'package:flutter/foundation.dart';
import 'package:storryca/src/core/network/api_client.dart';
import 'package:storryca/src/core/network/models/author_request_api_model.dart';
import 'package:storryca/src/core/network/models/login_activity_api_model.dart';
import 'package:storryca/src/core/network/models/notification_api_model.dart';
import 'package:storryca/src/core/network/models/security_alert_api_model.dart';
import 'package:storryca/src/core/network/models/session_api_model.dart';
import 'package:storryca/src/core/network/models/user_api_model.dart';

class UsersRepository {
  UsersRepository(this._client);

  final ApiClient _client;

  /// Whether this reader may see books rated 18+. False until they answer
  /// the age question, and for anyone signed out. The server already hides
  /// 18+ books from everyone else everywhere; this only decides what the app
  /// offers, e.g. the 18+ option in the Rank filter.
  final ValueNotifier<bool> isAdult = ValueNotifier(false);

  /// `asked` is false for accounts made before the age question existed (and
  /// Google sign-ups) — the app asks them once, as the website does.
  Future<({bool asked, bool isAdult})> ageStatus(String token) async {
    final data =
        await _client.get('/users/age-check', token: token)
            as Map<String, dynamic>;
    final adult = data['is_adult'] as bool? ?? false;
    isAdult.value = adult;
    return (asked: data['asked'] as bool? ?? false, isAdult: adult);
  }

  Future<void> saveAge(bool adult, String token) async {
    await _client.post(
      '/users/age-check',
      body: {'is_adult': adult},
      token: token,
    );
    isAdult.value = adult;
  }

  Future<UserApiModel> me(String token) async {
    final data =
        await _client.get('/users/me', token: token) as Map<String, dynamic>;
    return UserApiModel.fromJson(data);
  }

  /// Uploads a new profile photo. Returns the new filename (e.g.
  /// "avatar_15_6aa9....jpg") to pass to `avatarUrl()` for display.
  Future<String> uploadAvatar(String filePath, String token) async {
    final data =
        await _client.postFile(
              '/users/avatar',
              fileField: 'image',
              filePath: filePath,
              token: token,
            )
            as Map<String, dynamic>;
    return data['image'] as String;
  }

  /// A FULL REPLACE, not a patch: any field left out is saved empty. So
  /// every save sends all ten — the [current] profile (fresh from [me]) with
  /// only the edited ones swapped in. name/username/email are required on
  /// every save (422 otherwise); 400 when the email is already in use.
  ///
  /// The endpoint's response doesn't include every `/users/me` field (no
  /// `is_author`/counts), so callers should re-fetch [me] afterwards rather
  /// than trust this call's return shape for the full profile.
  Future<void> updateProfile(
    String token, {
    required UserApiModel current,
    String? name,
    String? username,
    String? email,
    String? phone,
    String? aboutMe,
    String? location,
    String? language,
    String? availability,
    String? aboutMyBooks,
    String? toMyReaders,
  }) async {
    await _client.post(
      '/users/profile',
      token: token,
      body: {
        'name': name ?? current.name ?? '',
        'username': username ?? current.username ?? '',
        'email': email ?? current.email,
        'phone': phone ?? current.phone ?? '',
        'about_me': aboutMe ?? current.aboutMe ?? '',
        'location': location ?? current.location,
        'language': language ?? current.language,
        'availability': availability ?? current.availability,
        'about_my_books': aboutMyBooks ?? current.aboutMyBooks,
        'to_my_readers': toMyReaders ?? current.toMyReaders,
      },
    );
  }

  Future<List<NotificationApiModel>> notifications(String token) async {
    final data = await _client.get(
      '/users/notifications',
      query: {'type': 'all', 'limit': 100},
      token: token,
    );
    final rawItems = data is Map<String, dynamic>
        ? (data['items'] as List? ?? [])
        : (data as List? ?? []);
    return rawItems
        .map((e) => NotificationApiModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> markNotificationRead(int notificationId, String token) async {
    await _client.post(
      '/users/notifications/read',
      body: {'notification_id': notificationId},
      token: token,
    );
  }

  // ── Push device token ────────────────────────────────────────────

  /// Safe to repeat — the server doesn't store the same token twice.
  Future<void> registerDeviceToken({
    required String fcmToken,
    required String appVersion,
    required String token,
  }) async {
    await _client.post(
      '/users/device-token',
      body: {
        'token': fcmToken,
        'platform': 'android',
        'app_version': appVersion,
      },
      token: token,
    );
  }

  /// On sign-out, so the next account on this device doesn't get this
  /// account's pushes.
  Future<void> unregisterDeviceToken(String fcmToken, String token) async {
    await _client.delete(
      '/users/device-token',
      body: {'token': fcmToken},
      token: token,
    );
  }

  // ── Active Sessions ──────────────────────────────────────────────

  Future<List<SessionApiModel>> sessions(String token) async {
    final data = await _client.get('/users/sessions', token: token) as List;
    return data
        .map((e) => SessionApiModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> revokeSession(int sessionId, String token) async {
    await _client.post(
      '/users/sessions/revoke',
      token: token,
      body: {'session_id': sessionId},
    );
  }

  Future<void> revokeOtherSessions(String token) async {
    await _client.post('/users/sessions/revoke-others', token: token);
  }

  // ── Login Activity ───────────────────────────────────────────────

  Future<List<LoginActivityApiModel>> loginActivity(String token) async {
    final data =
        await _client.get('/users/login-activity', token: token) as List;
    return data
        .map((e) => LoginActivityApiModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // ── Security Alerts ──────────────────────────────────────────────

  Future<List<SecurityAlertApiModel>> securityAlerts(String token) async {
    final data =
        await _client.get('/users/security-alerts', token: token) as List;
    return data
        .map((e) => SecurityAlertApiModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> markAlertRead(int alertId, String token) async {
    await _client.post(
      '/users/security-alerts/read',
      token: token,
      body: {'alert_id': alertId},
    );
  }

  Future<void> markAllAlertsRead(String token) async {
    await _client.post('/users/security-alerts/read-all', token: token);
  }

  // ── Change Password ──────────────────────────────────────────────

  /// Permanently deletes the signed-in account. Server-side, an author's
  /// approved/published stories are kept (detached from the account) under
  /// Storryca's publishing agreement; only personal data and drafts go.
  ///
  /// Same call as the website's Settings page: the current password plus
  /// the typed word DELETE. 422 "Current password is required.", 400
  /// "Current password is incorrect." (`DELETE /users/me` never existed.)
  Future<void> deleteAccount(
    String token, {
    required String currentPassword,
    required String confirm,
  }) async {
    await _client.post(
      '/users/delete-account',
      body: {'current_password': currentPassword, 'confirm': confirm},
      token: token,
    );
  }

  Future<void> changePassword(
    String token, {
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    await _client.post(
      '/users/password',
      token: token,
      body: {
        'current_password': currentPassword,
        'new_password': newPassword,
        'confirm_password': confirmPassword,
      },
    );
  }

  // ── Author Application ───────────────────────────────────────────

  /// Null when the reader has never applied.
  Future<AuthorRequestApiModel?> authorRequestStatus(String token) async {
    final data =
        await _client.get('/users/author-request/status', token: token)
            as Map<String, dynamic>;
    return data.isEmpty ? null : AuthorRequestApiModel.fromJson(data);
  }

  Future<void> submitAuthorRequest(String token, {String source = 'apply_now'}) async {
    await _client.post(
      '/users/author-request/submit',
      token: token,
      body: {'source': source},
    );
  }
}
