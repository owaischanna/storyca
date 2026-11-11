import 'package:storryca/src/core/network/device_service.dart';
import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

/// A hung request (dead network, server not responding) would otherwise
/// leave a loading screen stuck forever instead of failing fast. Real
/// responses from this API normally land in well under 2 seconds, so 10s
/// already gives a slow mobile connection generous room — and keeps the
/// worst case (this timeout plus the one automatic retry below) under the
/// ~20s ceiling a stuck screen should never cross.
const Duration _requestTimeout = Duration(seconds: 10);

class ApiException implements Exception {
  ApiException(
    this.message, {
    this.statusCode,
    this.retryAfterSeconds,
    this.isTimeout = false,
    this.code,
    this.data,
  });

  /// The refusal's `data` block — e.g. `{chapters, required}` on the
  /// mark-as-completed 422 — for building a message from fields rather than
  /// parsing [message].
  final Map<String, dynamic>? data;

  /// Signed out, or the session lapsed server-side: send the reader to Sign
  /// In rather than showing this as a failure.
  bool get needsSignIn => code == 'not_signed_in' || code == 'session_expired';

  /// A chapter past the free ones: `sign_in_required` (401, nobody signed
  /// in) or `unlock_required` (402, signed in but the book isn't unlocked).
  /// [data] then carries `title`, `preview`, `free_chapters` and `price`.
  bool get isChapterLocked =>
      code == 'sign_in_required' || code == 'unlock_required';

  final String message;
  final int? statusCode;

  /// `data.code` from a refusal — e.g. `not_signed_in`, `session_expired`,
  /// `not_permitted` on a 403. Branch on this, never on [message] text.
  final String? code;

  /// From the `Retry-After` header on a 503 — how long to wait before
  /// retrying, when the server suggested one.
  final int? retryAfterSeconds;

  /// Set when this came from a request timeout rather than a server
  /// response, so callers (and the client's own retry) can tell the two
  /// apart without string-matching [message].
  final bool isTimeout;

  bool get isUnauthorized => statusCode == 401;
  bool get isNotFound => statusCode == 404;
  bool get isServiceUnavailable => statusCode == 503;

  /// The wallet doesn't have enough coins, or the chapter/book being read
  /// hasn't been unlocked yet — callers send the reader to the unlock or
  /// top-up flow instead of treating this like any other error.
  bool get isPaymentRequired => statusCode == 402;
  bool get isForbidden => statusCode == 403;
  bool get isUnprocessable => statusCode == 422;
  bool get isTooManyRequests => statusCode == 429;

  @override
  String toString() => message;

  /// A gentler message for failures a reader would otherwise read as
  /// developer jargon: a request that timed out, or a session getting
  /// rejected as forbidden, both just look like "the app is stuck" to them —
  /// so both are shown as a connectivity issue rather than surfacing which
  /// one it technically was.
  String get displayMessage =>
      (isTimeout || isForbidden) ? 'Slow internet connection.' : message;
}

class ApiClient {
  ApiClient({http.Client? httpClient}) : _httpClient = httpClient ?? http.Client();

  /// Called whenever any request comes back 401 — the token it was sent
  /// with is no longer valid (expired or revoked), so whatever is holding
  /// onto it should forget it immediately rather than keep presenting a
  /// logged-in state the server no longer honors. Wired in `api.dart` to
  /// [AuthService.logout], so an expired session clears itself the moment
  /// any authenticated call actually discovers it's expired — the reader
  /// never has to notice and sign out manually first.
  void Function()? onUnauthorized;

  /// The signed-in reader's token, set by [AuthService]. Used by calls whose
  /// RESULTS depend on who is asking (which books an 18+ reader may see)
  /// even though they also work signed out — see [readerToken].
  Future<String?> Function()? tokenProvider;

  /// The current reader's token, or null when signed out. Without it those
  /// calls look anonymous, and the server falls back to a login cookie that
  /// is lost on app restart — which made 18+ books appear and vanish.
  Future<String?> readerToken() async =>
      tokenProvider == null ? null : await tokenProvider!();

  static const String baseUrl = 'https://storryca.com/api';

  final http.Client _httpClient;

  /// The account endpoints (/users/sessions, /users/security-alerts, etc.)
  /// look at the session cookie alongside the Bearer token. This client is a
  /// single instance created before any login call and reused for every
  /// request for the life of the app, so keeping the cookie jar here — rather
  /// than per-request — satisfies "one persistent cookie store used from
  /// login onwards."
  final Map<String, String> _cookies = {};

  /// Clears the session cookie on logout so the next login starts clean.
  /// [signedOutToken] is the token just retired: a reply to a request still
  /// carrying it (e.g. the push unregister sent right after sign-out) must
  /// not hand the jar a session cookie again — the server would keep
  /// treating this device as the old account (it decides free vs. locked
  /// chapters, and 18+ books, from that cookie).
  void clearCookies({String? signedOutToken}) {
    _cookies.clear();
    if (signedOutToken != null) _retiredTokens.add(signedOutToken);
  }

  final Set<String> _retiredTokens = {};

  /// What a Storryca address outside the JSON API (e.g. the chapter-audio
  /// stream the website plays) needs to recognise the reader: their token,
  /// the login session cookie and the app's User-Agent.
  Future<Map<String, String>> readerHeaders() async {
    final token = await readerToken();
    return {
      if (token != null) 'Authorization': 'Bearer $token',
      ..._cookieHeader,
      'User-Agent': await _ua(),
    };
  }

  void _updateCookiesFromResponse(http.Response response) {
    final setCookie = response.headers['set-cookie'];
    if (setCookie == null) return;
    final auth = response.request?.headers['Authorization'];
    if (auth != null &&
        auth.startsWith('Bearer ') &&
        _retiredTokens.contains(auth.substring(7))) {
      return;
    }
    // Multiple Set-Cookie headers arrive comma-joined; a plain split on ","
    // would also cut through the comma inside an Expires date, so this only
    // splits where a new "name=" pair actually starts.
    final parts = setCookie.split(RegExp(r',(?=\s*[^=;]+=)'));
    for (final part in parts) {
      final pair = part.split(';').first.trim();
      final eq = pair.indexOf('=');
      if (eq > 0) {
        _cookies[pair.substring(0, eq)] = pair.substring(eq + 1);
      }
    }
  }

  /// Built lazily on the first request (so it's ready before /login even
  /// after a hot restart) and reused for every call after.
  Future<String>? _userAgent;
  Future<String> _ua() => _userAgent ??= buildAppUserAgent();

  Map<String, String> get _cookieHeader => _cookies.isEmpty
      ? const {}
      : {
          'Cookie': _cookies.entries
              .map((e) => '${e.key}=${e.value}')
              .join('; '),
        };

  /// Returns the decoded `data` field of the API envelope. This is a `Map`
  /// for most endpoints (e.g. `{items, pagination}` or a single resource) but
  /// a bare `List` for a few (e.g. `/stories/genres`) — callers cast to what
  /// that endpoint documents.
  Future<dynamic> get(
    String path, {
    Map<String, dynamic>? query,
    String? token,
  }) async {
    final params = <String, String>{};
    query?.forEach((key, value) {
      if (value != null) params[key] = value.toString();
    });

    final uri = Uri.parse('$baseUrl$path').replace(
      queryParameters: params.isEmpty ? null : params,
    );

    Future<http.Response> send() async {
      try {
        return await _httpClient
            .get(
              uri,
              headers: {
                if (token != null) 'Authorization': 'Bearer $token',
                ..._cookieHeader,
                'User-Agent': await _ua(),
              },
            )
            .timeout(_requestTimeout);
      } on TimeoutException {
        throw ApiException(
          'The server took too long to respond. Try again.',
          isTimeout: true,
        );
      } catch (_) {
        throw ApiException('Could not reach the server. Check your connection.');
      }
    }

    return _decodeWithRetry(send, authed: token != null);
  }

  /// Posts a JSON [body] and returns the decoded `data` field, same rules as
  /// [get]. Pass [includeEnvelope] to get the whole response body back
  /// instead (needed for endpoints like `/register` that put fields, such as
  /// `token`, outside of `data`).
  Future<dynamic> post(
    String path, {
    Map<String, dynamic>? body,
    String? token,
    bool includeEnvelope = false,
    Map<String, String>? extraHeaders,
    // For slow calls (chapter narration takes 10-20 s) — and [retry] false
    // for any call that must never be sent twice, e.g. one that can cost
    // money.
    Duration? timeout,
    bool retry = true,
  }) async {
    final uri = Uri.parse('$baseUrl$path');

    Future<http.Response> send() async {
      try {
        return await _httpClient
            .post(
              uri,
              headers: {
                'Content-Type': 'application/json',
                if (token != null) 'Authorization': 'Bearer $token',
                ..._cookieHeader,
                'User-Agent': await _ua(),
                ...?extraHeaders,
              },
              body: jsonEncode(body ?? const {}),
            )
            .timeout(timeout ?? _requestTimeout);
      } on TimeoutException {
        throw ApiException(
          'The server took too long to respond. Try again.',
          isTimeout: true,
        );
      } catch (_) {
        throw ApiException('Could not reach the server. Check your connection.');
      }
    }

    if (!retry) {
      return _decode(
        await send(),
        includeEnvelope: includeEnvelope,
        authed: token != null,
      );
    }
    return _decodeWithRetry(
      send,
      includeEnvelope: includeEnvelope,
      authed: token != null,
    );
  }

  /// Sends a DELETE request and returns the decoded `data` field, same rules
  /// as [get]. Most deletes take their target via [query]; the moderation and
  /// review-comment deletes take a JSON [body] instead.
  Future<dynamic> delete(
    String path, {
    Map<String, dynamic>? query,
    Map<String, dynamic>? body,
    String? token,
  }) async {
    final params = <String, String>{};
    query?.forEach((key, value) {
      if (value != null) params[key] = value.toString();
    });

    final uri = Uri.parse('$baseUrl$path').replace(
      queryParameters: params.isEmpty ? null : params,
    );

    Future<http.Response> send() async {
      try {
        return await _httpClient
            .delete(
              uri,
              headers: {
                if (body != null) 'Content-Type': 'application/json',
                if (token != null) 'Authorization': 'Bearer $token',
                ..._cookieHeader,
                'User-Agent': await _ua(),
              },
              body: body == null ? null : jsonEncode(body),
            )
            .timeout(_requestTimeout);
      } on TimeoutException {
        throw ApiException(
          'The server took too long to respond. Try again.',
          isTimeout: true,
        );
      } catch (_) {
        throw ApiException('Could not reach the server. Check your connection.');
      }
    }

    return _decodeWithRetry(send, authed: token != null);
  }

  /// Sends a `multipart/form-data` request and returns the decoded `data`
  /// field, same rules as [get]. [fileField]/[filePath] attach one file
  /// (omit both when the request carries no file at all, e.g. saving a
  /// story draft with no cover yet); [fields] are the other form fields sent
  /// alongside it — needed because endpoints like `POST /stories` carry many
  /// text fields together with the cover image in one multipart body.
  Future<dynamic> postFile(
    String path, {
    String? fileField,
    String? filePath,
    Map<String, String>? fields,
    String? token,
    // More file parts alongside [fileField], as {field: path} — e.g. a
    // story's trailer next to its cover.
    Map<String, String>? extraFiles,
    // For big uploads (a trailer can be 30MB) — and [retry] false so a slow
    // upload is never silently sent a second time.
    Duration? timeout,
    bool retry = true,
  }) async {
    final uri = Uri.parse('$baseUrl$path');

    Future<http.Response> send() async {
      try {
        final request = http.MultipartRequest('POST', uri)
          ..headers.addAll({
            if (token != null) 'Authorization': 'Bearer $token',
            ..._cookieHeader,
                'User-Agent': await _ua(),
          })
          ..fields.addAll(fields ?? const {});
        if (fileField != null && filePath != null) {
          request.files.add(
            await http.MultipartFile.fromPath(fileField, filePath),
          );
        }
        for (final file in (extraFiles ?? const <String, String>{}).entries) {
          request.files.add(
            await http.MultipartFile.fromPath(file.key, file.value),
          );
        }
        final streamed = await _httpClient
            .send(request)
            .timeout(timeout ?? _requestTimeout);
        return await http.Response.fromStream(streamed);
      } on TimeoutException {
        throw ApiException(
          'The server took too long to respond. Try again.',
          isTimeout: true,
        );
      } catch (_) {
        throw ApiException('Could not reach the server. Check your connection.');
      }
    }

    if (!retry) {
      return _decode(await send(), authed: token != null);
    }
    return _decodeWithRetry(send, authed: token != null);
  }

  /// Sends via [send] and decodes the result, retrying once if the first
  /// attempt either times out (the shared-hosting backend is occasionally
  /// slow on a cold connection, but fast again right after) or comes back as
  /// a bare HTTP redirect (a 3xx with an HTML body instead of JSON — seen
  /// intermittently from the CDN in front of the API) that the underlying
  /// HTTP client didn't already follow. This turns most of those transient
  /// hiccups into a normal, if slightly slower, successful load instead of
  /// surfacing an error the user has to manually retry.
  Future<dynamic> _decodeWithRetry(
    Future<http.Response> Function() send, {
    bool includeEnvelope = false,
    bool authed = false,
  }) async {
    final http.Response response;
    try {
      response = await send();
    } on ApiException {
      // send() only throws for transport failures (timeout, or a pooled
      // connection the OS closed while the app was in the background), so a
      // single retry on a fresh connection is safe and usually succeeds.
      final retryResponse = await send();
      return _decode(
        retryResponse,
        includeEnvelope: includeEnvelope,
        authed: authed,
      );
    }
    if (response.statusCode >= 300 &&
        response.statusCode < 400 &&
        response.headers['content-type']?.contains('json') != true) {
      final retryResponse = await send();
      return _decode(
        retryResponse,
        includeEnvelope: includeEnvelope,
        authed: authed,
      );
    }
    return _decode(response, includeEnvelope: includeEnvelope, authed: authed);
  }

  dynamic _decode(
    http.Response response, {
    bool includeEnvelope = false,
    bool authed = false,
  }) {
    Map<String, dynamic> body;
    try {
      body = jsonDecode(response.body) as Map<String, dynamic>;
    } catch (_) {
      throw ApiException(
        'Unexpected response from the server.',
        statusCode: response.statusCode,
      );
    }

    final status = body['status'];
    if (status != true) {
      final rawMessage = body['message'];
      final message = rawMessage is String
          ? rawMessage
          : rawMessage is Map
          ? rawMessage.values.join(', ')
          : 'Something went wrong.';
      final retryAfter = int.tryParse(response.headers['retry-after'] ?? '');
      final data = body['data'];
      final code = data is Map ? data['code'] as String? : null;
      // A 403 not_signed_in / session_expired means the same as a 401: the
      // token sent is no longer honoured (e.g. the session was revoked or
      // pushed out). Without this the app stays half signed-in and every
      // screen shows a generic error instead of going back to Sign In.
      // not_signed_in only counts when a token was actually sent — a call
      // that simply omitted it mustn't sign the reader out.
      // A 401 `sign_in_required` is a locked chapter asked for by someone
      // with no account, not an expired session — never sign anyone out
      // over it.
      if ((response.statusCode == 401 && code != 'sign_in_required') ||
          code == 'session_expired' ||
          (authed && code == 'not_signed_in')) {
        onUnauthorized?.call();
      }
      throw ApiException(
        message,
        statusCode: response.statusCode,
        retryAfterSeconds: retryAfter,
        code: code,
        data: data is Map<String, dynamic> ? data : null,
      );
    }

    // Only trust cookies from a successful response — a 403 can come with a
    // freshly-issued guest session cookie that would otherwise silently
    // replace the valid authenticated one and break every request after it.
    _updateCookiesFromResponse(response);

    if (includeEnvelope) return body;
    return body['data'] ?? const <String, dynamic>{};
  }
}
