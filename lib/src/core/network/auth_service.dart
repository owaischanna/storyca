import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:storryca/src/core/network/api_client.dart';

const String _tokenKey = 'auth_token';
const String _loginAtKey = 'auth_login_at';

/// How long a sign-in lasts before the reader is signed out and must log
/// in again.
const Duration sessionLifetime = Duration(days: 14);

class AuthResult {
  AuthResult({
    required this.token,
    required this.email,
    required this.requiresEmailVerification,
    this.requires2fa = false,
  });

  /// Null only when [requires2fa] is true — the server holds a pending
  /// session (cookie-based) instead of issuing a token until the code at
  /// `/login/verify-2fa` is confirmed.
  final String? token;
  final String email;
  final bool requiresEmailVerification;
  final bool requires2fa;
}

class TwoFactorSetup {
  TwoFactorSetup({
    required this.secret,
    required this.otpauthUrl,
    required this.qrUrl,
  });

  final String secret;
  final String otpauthUrl;
  final String qrUrl;

  factory TwoFactorSetup.fromJson(Map<String, dynamic> json) =>
      TwoFactorSetup(
        secret: json['secret'] as String? ?? '',
        otpauthUrl: json['otpauth_url'] as String? ?? '',
        qrUrl: json['qr_url'] as String? ?? '',
      );
}

class EmailVerificationStatus {
  EmailVerificationStatus({
    required this.verified,
    required this.email,
    required this.expiresAtUnix,
  });

  final bool verified;
  final String email;
  final int expiresAtUnix;

  factory EmailVerificationStatus.fromJson(Map<String, dynamic> json) =>
      EmailVerificationStatus(
        verified: json['verified'] as bool? ?? false,
        email: json['email'] as String? ?? '',
        expiresAtUnix: (json['expires_at_unix'] as num?)?.toInt() ?? 0,
      );
}

class AuthService {
  AuthService(this._client) {
    // A 401 means whatever token was sent is no longer valid — forget it
    // right away so the app can't keep presenting a logged-in state the
    // server has already stopped honoring.
    _client.onUnauthorized = _expireSession;
  }

  final ApiClient _client;

  Future<AuthResult> login(String email, String password) async {
    final body =
        await _client.post(
              '/login',
              body: {'email': email, 'password': password, 'role': 'user'},
              includeEnvelope: true,
            )
            as Map<String, dynamic>;

    final data = (body['data'] as Map<String, dynamic>?) ?? const {};
    final requires2fa = data['requires_2fa'] as bool? ?? false;
    final token = body['token'] as String?;

    // A 2FA-enabled account gets no token here — the server holds a pending
    // session (via cookie) until /login/verify-2fa confirms the code, so
    // only a *non*-2FA login without a token is actually an error.
    if (!requires2fa && (token == null || token.isEmpty)) {
      throw ApiException('Login succeeded but no token was returned.');
    }
    if (token != null && token.isNotEmpty) {
      await _saveToken(token);
    }

    return AuthResult(
      token: token,
      email: data['email'] as String? ?? email,
      requiresEmailVerification:
          data['requires_email_verification'] as bool? ?? false,
      requires2fa: requires2fa,
    );
  }

  /// The backend verifies the ID token's `aud` against this WEB client id, so
  /// Android must request the token with it as `serverClientId` — using the
  /// Android OAuth client id instead makes every sign-in fail with a 401.
  static const String _googleWebClientId =
      '1061119779863-ohoel3v8k84ujldlhruha678isrqbahs.apps.googleusercontent.com';
  bool _googleInitialized = false;

  /// Returns null if the reader cancelled the Google picker.
  Future<AuthResult?> loginWithGoogle() async {
    final google = GoogleSignIn.instance;
    if (!_googleInitialized) {
      await google.initialize(serverClientId: _googleWebClientId);
      _googleInitialized = true;
    }
    final GoogleSignInAccount account;
    try {
      account = await google.authenticate();
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) return null;
      throw ApiException('Google sign-in failed. Try again.');
    }
    final idToken = account.authentication.idToken;
    if (idToken == null || idToken.isEmpty) {
      throw ApiException('Google did not return a sign-in token.');
    }

    final body =
        await _client.post(
              '/login/google',
              body: {'credential': idToken},
              includeEnvelope: true,
            )
            as Map<String, dynamic>;
    final token = body['token'] as String?;
    if (token == null || token.isEmpty) {
      throw ApiException('Google sign-in succeeded but no token was returned.');
    }
    await _saveToken(token);
    final data = (body['data'] as Map<String, dynamic>?) ?? const {};
    return AuthResult(
      token: token,
      email: data['email'] as String? ?? account.email,
      requiresEmailVerification: false,
    );
  }

  /// The second step of signing in to a 2FA-enabled account. The pending
  /// session lives in the cookie `ApiClient` already carries from the
  /// `/login` call — this call takes no token of its own.
  Future<AuthResult> verifyTwoFactor(String code) async {
    final body =
        await _client.post(
              '/login/verify-2fa',
              body: {'code': code},
              includeEnvelope: true,
            )
            as Map<String, dynamic>;

    final token = body['token'] as String?;
    if (token == null || token.isEmpty) {
      throw ApiException('Verification succeeded but no token was returned.');
    }
    await _saveToken(token);

    final data = (body['data'] as Map<String, dynamic>?) ?? const {};
    return AuthResult(
      token: token,
      email: data['email'] as String? ?? '',
      requiresEmailVerification: false,
    );
  }

  Future<TwoFactorSetup> setupTwoFactor(String token) async {
    final data =
        await _client.post('/users/two-factor/setup', token: token)
            as Map<String, dynamic>;
    return TwoFactorSetup.fromJson(data);
  }

  Future<void> enableTwoFactor(String token, String code) async {
    await _client.post(
      '/users/two-factor/enable',
      body: {'code': code},
      token: token,
    );
  }

  Future<void> disableTwoFactor({
    required String token,
    required String code,
    required String currentPassword,
  }) async {
    await _client.post(
      '/users/two-factor/disable',
      body: {'code': code, 'current_password': currentPassword},
      token: token,
    );
  }

  Future<AuthResult> register(
    String email,
    String password,
    String passwordConfirmation,
  ) async {
    final body =
        await _client.post(
              '/register',
              body: {
                'email': email,
                'password': password,
                'password_confirmation': passwordConfirmation,
                'auth_provider': 'email',
              },
              includeEnvelope: true,
            )
            as Map<String, dynamic>;

    final token = body['token'] as String?;
    if (token == null || token.isEmpty) {
      throw ApiException('Registration succeeded but no token was returned.');
    }
    await _saveToken(token);

    final data = (body['data'] as Map<String, dynamic>?) ?? const {};
    return AuthResult(
      token: token,
      email: email,
      requiresEmailVerification:
          data['requires_email_verification'] as bool? ?? false,
    );
  }

  Future<EmailVerificationStatus> emailVerificationStatus(String token) async {
    final data =
        await _client.get('/users/email-verification/status', token: token)
            as Map<String, dynamic>;
    return EmailVerificationStatus.fromJson(data);
  }

  Future<void> verifyEmail(String token, String code) async {
    await _client.post(
      '/users/email-verification/verify',
      body: {'code': code},
      token: token,
    );
  }

  /// Returns the new code's expiry as a unix timestamp.
  Future<int> resendVerificationEmail(String token) async {
    final data =
        await _client.post('/users/email-verification/resend', token: token)
            as Map<String, dynamic>;
    return (data['expires_at_unix'] as num?)?.toInt() ?? 0;
  }

  /// Called after the session is ended by the 14-day limit or a 401, so
  /// the app can send the reader to Sign In.
  void Function()? onSessionExpired;

  /// Fired after every successful sign-in (password, Google, 2FA, sign-up) —
  /// used to register this device for push notifications.
  void Function()? onSignedIn;

  /// Fired on every sign-out with the token that was in use, after it has
  /// been cleared locally — used to unregister this device's push token.
  void Function(String token)? onSignedOut;

  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    await prefs.setInt(_loginAtKey, DateTime.now().millisecondsSinceEpoch);
    onSignedIn?.call();
  }

  /// The saved token, or null once [sessionLifetime] has passed since
  /// sign-in (the session is then cleared and [onSessionExpired] fires).
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_tokenKey);
    if (token == null) return null;
    final loginAt = prefs.getInt(_loginAtKey);
    if (loginAt == null) {
      // Signed in before this limit existed — start their 14 days now
      // rather than signing them out the moment they update.
      await prefs.setInt(_loginAtKey, DateTime.now().millisecondsSinceEpoch);
      return token;
    }
    final age = DateTime.now().difference(
      DateTime.fromMillisecondsSinceEpoch(loginAt),
    );
    if (age >= sessionLifetime) {
      await _expireSession();
      return null;
    }
    return token;
  }

  Future<void> _expireSession() async {
    final prefs = await SharedPreferences.getInstance();
    final hadSession = prefs.getString(_tokenKey) != null;
    await logout();
    if (hadSession) onSessionExpired?.call();
  }

  Future<bool> isLoggedIn() async => (await getToken()) != null;

  Future<void> logout() async {
    // So the next Google sign-in shows the account picker again.
    if (_googleInitialized) {
      try {
        await GoogleSignIn.instance.signOut();
      } catch (_) {}
    }
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_tokenKey);
    await prefs.remove(_tokenKey);
    await prefs.remove(_loginAtKey);
    _client.clearCookies();
    // Cleared first, so a 401 from the unregister call can't loop back here
    // with a session still on disk.
    if (token != null) onSignedOut?.call(token);
  }
}
