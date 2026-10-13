import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:storryca/src/core/network/api_client.dart';
import 'package:storryca/src/core/network/auth_service.dart';
import 'package:storryca/src/core/network/repositories/users_repository.dart';

/// Must match `default_notification_channel_id` in AndroidManifest.xml, so
/// pushes the system draws (app in background/closed) and the ones drawn
/// here (app in foreground) land in the same channel.
const AndroidNotificationChannel _channel = AndroidNotificationChannel(
  'storryca_updates',
  'Updates',
  description: 'New chapters, replies and account activity.',
  importance: Importance.high,
);

const String _statusIcon = 'ic_stat_notification';
const String _askedKey = 'push_permission_asked';
const String _pendingUnregisterKey = 'push_pending_unregister';

final FlutterLocalNotificationsPlugin _local = FlutterLocalNotificationsPlugin();

Future<void> _initLocal({
  void Function(NotificationResponse response)? onTap,
}) async {
  await _local.initialize(
    const InitializationSettings(
      android: AndroidInitializationSettings(_statusIcon),
    ),
    onDidReceiveNotificationResponse: onTap,
  );
  await _local
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >()
      ?.createNotificationChannel(_channel);
}

NotificationDetails _details({
  StyleInformation? style,
  AndroidBitmap<Object>? largeIcon,
}) => NotificationDetails(
  android: AndroidNotificationDetails(
    _channel.id,
    _channel.name,
    channelDescription: _channel.description,
    importance: Importance.high,
    priority: Priority.high,
    icon: _statusIcon,
    styleInformation: style,
    largeIcon: largeIcon,
    // The cover arrives as an update to the same notification — it must not
    // sound or pop up a second time.
    onlyAlertOnce: true,
  ),
);

/// Android doesn't draw a push itself while the app is in the foreground (or
/// for a data-only message), so those are drawn here. The message data rides
/// along as the payload so a tap can deep link like a system one.
///
/// The plain title-and-body notification goes up straight away; the cover
/// (new-release pushes carry `notification.image`) is fetched afterwards and,
/// if it arrives in time, replaces it in place. So a slow, failed or missing
/// image can only ever cost the picture — never the notification.
Future<void> _show(RemoteMessage message) async {
  final title = message.notification?.title ?? message.data['title'] as String?;
  final body = message.notification?.body ?? message.data['body'] as String?;
  if (title == null && body == null) return;
  final id = DateTime.now().millisecondsSinceEpoch.remainder(1 << 31);
  final payload = jsonEncode(message.data);
  await _local.show(id, title, body, _details(), payload: payload);

  final imageUrl =
      message.notification?.android?.imageUrl ??
      message.data['image'] as String?;
  if (imageUrl == null || imageUrl.isEmpty) return;
  final file = await _downloadImage(imageUrl);
  if (file == null) return;
  try {
    // Tapped or swiped away while the cover downloaded — don't bring it back.
    final active = await _local
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.getActiveNotifications();
    if (active != null && !active.any((n) => n.id == id)) return;
    final cover = FilePathAndroidBitmap(file.path);
    await _local.show(
      id,
      title,
      body,
      _details(
        // largeIcon too, so the collapsed notification shows the cover.
        largeIcon: cover,
        style: BigPictureStyleInformation(
          cover,
          largeIcon: cover,
          hideExpandedLargeIcon: true,
          contentTitle: title,
          summaryText: body,
        ),
      ),
      payload: payload,
    );
  } catch (_) {
    // The plain notification is already up.
  } finally {
    // The bitmap is decoded when the notification is posted, so the file
    // isn't needed after this.
    try {
      await file.delete();
    } catch (_) {}
  }
}

const Duration _imageTimeout = Duration(seconds: 3);
const int _maxImageBytes = 5 * 1024 * 1024;

/// Android's notification styles can't take a URL, only a file. Null on any
/// failure — a non-https URL, a timeout, a non-image or oversized response.
Future<File?> _downloadImage(String url) async {
  final uri = Uri.tryParse(url);
  if (uri == null || uri.scheme != 'https') return null;
  try {
    final dir = Directory(
      '${(await getTemporaryDirectory()).path}/push_images',
    );
    await dir.create(recursive: true);
    await _sweepOldImages(dir);
    final started = DateTime.now();
    final response = await http.get(uri).timeout(_imageTimeout);
    final type = response.headers['content-type'] ?? '';
    if (response.statusCode != 200 ||
        !type.startsWith('image/') ||
        response.bodyBytes.isEmpty ||
        response.bodyBytes.length > _maxImageBytes) {
      if (kDebugMode) {
        debugPrint('Push: cover rejected (${response.statusCode}, $type)');
      }
      return null;
    }
    final file = File('${dir.path}/${DateTime.now().microsecondsSinceEpoch}');
    await file.writeAsBytes(response.bodyBytes);
    if (kDebugMode) {
      final ms = DateTime.now().difference(started).inMilliseconds;
      debugPrint('Push: cover ready in ${ms}ms');
    }
    return file;
  } catch (e) {
    if (kDebugMode) debugPrint('Push: no cover (${e.runtimeType})');
    return null;
  }
}

/// Covers are deleted once posted; this only catches leftovers from a
/// process that died mid-download.
Future<void> _sweepOldImages(Directory dir) async {
  final cutoff = DateTime.now().subtract(const Duration(hours: 1));
  try {
    await for (final entry in dir.list()) {
      if (entry is File && (await entry.lastModified()).isBefore(cutoff)) {
        await entry.delete();
      }
    }
  } catch (_) {}
}

/// Runs in its own isolate while the app is in the background or closed.
/// Top-level and marked as an entry point, or release builds tree-shake it
/// out and it only ever works in debug.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  // A message with a `notification` block is already drawn by the system.
  if (message.notification != null) return;
  await _initLocal();
  await _show(message);
}

/// Where a push should open: the story, chapter or profile it is about —
/// falling back to the Inbox (never just the home screen) when the payload
/// names something the app has no page for.
String routeForPush(Map<String, dynamic> data) {
  final id = int.tryParse('${data['id']}');
  final route = id == null
      ? null
      : switch ('${data['type']}'.toLowerCase()) {
          'story' => '/story/$id',
          'chapter' => '/read/$id',
          'profile' || 'user' || 'author' => '/author-profile/$id',
          _ => null,
        };
  // Wallet pushes carry no id. A withdrawal moving (processing / paid /
  // failed) opens the author's earnings; anything else the wallet.
  if ('${data['type']}'.toLowerCase() == 'wallet') {
    final withdrawal = '${data['withdrawal']}'.toLowerCase();
    return withdrawal == 'true' || withdrawal == '1'
        ? '/author-earnings'
        : '/transaction-history';
  }
  return route ?? '/inbox';
}

Map<String, dynamic> _decodePayload(String? payload) {
  if (payload == null || payload.isEmpty) return const {};
  try {
    return jsonDecode(payload) as Map<String, dynamic>;
  } catch (_) {
    return const {};
  }
}

/// Firebase Cloud Messaging: keeps this device's token registered with the
/// server for whoever is signed in, and turns pushes into deep links. The app
/// only ever holds the FCM token — sending happens server-side.
class PushService {
  PushService(this._users, this._auth);

  final UsersRepository _users;
  final AuthService _auth;
  GoRouter? _router;

  static const MethodChannel _settingsChannel = MethodChannel(
    'storryca/notifications',
  );

  /// Bumped whenever a push arrives or is opened. A push and an Inbox entry
  /// are the same record, so the Inbox and the unread badge reload on this.
  final ValueNotifier<int> inboxChanged = ValueNotifier(0);

  /// Whether the OS will show notifications. Null until first checked. When
  /// false nothing arrives and nothing errors, so the UI shows it instead.
  final ValueNotifier<bool?> permissionGranted = ValueNotifier(null);

  Future<String?>? _launchRoute;
  bool _registered = false;

  // Register/unregister calls run one at a time, in order — a sign-out
  // followed straight away by another account's sign-in must never let the
  // second registration race ahead of the first account's unregister.
  Future<void> _queue = Future.value();
  Future<void> _serial(Future<void> Function() task) {
    final next = _queue.then((_) => task());
    _queue = next.catchError((_) {});
    return next;
  }

  void _changed() => inboxChanged.value++;

  final Completer<void> _localReady = Completer();

  Future<void> init(GoRouter router) async {
    _router = router;
    // Closed → tapped. Started before any await so it's always in place by
    // the time Splash asks for it; consumed once Splash routes.
    _launchRoute = _resolveLaunchRoute();
    await _initLocal(onTap: (r) => _open(_decodePayload(r.payload)));
    _localReady.complete();

    // Foreground.
    FirebaseMessaging.onMessage.listen(handleForegroundMessage);
    // Background → tapped.
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      _changed();
      _open(message.data);
    });
    // Reinstall, cleared data, or FCM rotating it on its own — a stale token
    // on the server means pushes silently stop.
    FirebaseMessaging.instance.onTokenRefresh.listen((t) => sync(fcmToken: t));

    _auth.onSignedIn = () {
      sync();
      askOnce();
    };
    _auth.onSignedOut = _unregister;

    unawaited(refreshPermission());
    if (await _auth.isLoggedIn()) {
      unawaited(sync());
      unawaited(askOnce());
    }
  }

  /// What a push does while the app is open: draw it (Android won't) and
  /// refresh the Inbox and badge.
  void handleForegroundMessage(RemoteMessage message) {
    _show(message);
    _changed();
  }

  Future<String?> _resolveLaunchRoute() async {
    try {
      final message = await FirebaseMessaging.instance.getInitialMessage();
      if (message != null) {
        _changed();
        _markRead(message.data);
        return routeForPush(message.data);
      }
      // A foreground notification drawn by this app, tapped after the app
      // was closed.
      await _localReady.future;
      final details = await _local.getNotificationAppLaunchDetails();
      if (details?.didNotificationLaunchApp ?? false) {
        final data = _decodePayload(details!.notificationResponse?.payload);
        _markRead(data);
        return routeForPush(data);
      }
    } catch (_) {}
    return null;
  }

  /// The page a push opened the app on, if it was launched from one — once.
  Future<String?> takeLaunchRoute() async {
    final route = _launchRoute;
    _launchRoute = null;
    return route == null ? null : await route;
  }

  void _open(Map<String, dynamic> data) {
    _markRead(data);
    _router?.push(routeForPush(data));
  }

  void _markRead(Map<String, dynamic> data) {
    final id = int.tryParse('${data['notification_id']}');
    if (id == null) return;
    () async {
      final token = await _auth.getToken();
      if (token == null) return;
      try {
        await _users.markNotificationRead(id, token);
        _changed();
      } on ApiException {
        // The Inbox still shows it unread; nothing else depends on this.
      }
    }();
  }

  /// Registers this device for the signed-in account. Runs on sign-in, on
  /// app start, on token refresh, and on resume if the last try failed.
  Future<void> sync({String? fcmToken}) => _serial(() async {
    await _flushPendingUnregister();
    final token = await _auth.getToken();
    if (token == null) return;
    try {
      final fcm = fcmToken ?? await FirebaseMessaging.instance.getToken();
      if (fcm == null) return;
      final info = await PackageInfo.fromPlatform();
      await _users.registerDeviceToken(
        fcmToken: fcm,
        appVersion: info.version,
        token: token,
      );
      _registered = true;
      // Whose Inbox this is may have just changed (sign-in) — reload it.
      _changed();
      if (kDebugMode) {
        // Never the whole token, and nothing at all in release builds.
        debugPrint('Push: registered …${fcm.substring(fcm.length - 6)}');
      }
    } on ApiException catch (e) {
      // not_permitted won't change by retrying on every resume — leave it to
      // the next app start, sign-in or token refresh. not_signed_in /
      // session_expired: the next sign-in registers again.
      _registered = e.code == 'not_permitted';
      if (kDebugMode) debugPrint('Push: register refused (${e.code})');
    } catch (_) {
      // Offline, or Play services couldn't hand out a token yet.
      _registered = false;
    }
  });

  /// Called on resume — retries a registration that failed (e.g. offline).
  void onResume() {
    unawaited(refreshPermission());
    if (!_registered) unawaited(sync());
  }

  void _unregister(String authToken) => _serial(() async {
    _registered = false;
    String? fcm;
    try {
      fcm = await FirebaseMessaging.instance.getToken();
      if (fcm != null) await _users.unregisterDeviceToken(fcm, authToken);
      if (kDebugMode) debugPrint('Push: unregistered');
    } catch (_) {
      if (kDebugMode) debugPrint('Push: unregister failed, queued for retry');
      // Couldn't reach the server — keep the job and retry it before the
      // next registration, so the next person signing in on this device
      // doesn't get the previous account's pushes.
      if (fcm != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(
          _pendingUnregisterKey,
          jsonEncode({'fcm': fcm, 'auth': authToken}),
        );
      }
      // Also retire the token on FCM's side, so even the server's stale
      // record can no longer reach this device. Needs network too, so this
      // is best effort.
      try {
        await FirebaseMessaging.instance.deleteToken();
      } catch (_) {}
    }
    _changed();
  });

  Future<void> _flushPendingUnregister() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_pendingUnregisterKey);
    if (raw == null) return;
    final job = _decodePayload(raw);
    try {
      await _users.unregisterDeviceToken(
        job['fcm'] as String,
        job['auth'] as String,
      );
    } on ApiException catch (e) {
      // A refusal (old session already gone) won't change on retry; any
      // other failure is the network, so keep the job for next time.
      if (e.statusCode != 401 && e.statusCode != 403) return;
    } catch (_) {
      return;
    }
    await prefs.remove(_pendingUnregisterKey);
    if (kDebugMode) debugPrint('Push: queued unregister sent');
  }

  Future<bool> refreshPermission() async {
    try {
      final settings = await FirebaseMessaging.instance
          .getNotificationSettings();
      final granted =
          settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional;
      permissionGranted.value = granted;
      return granted;
    } catch (_) {
      return permissionGranted.value ?? false;
    }
  }

  /// The one automatic prompt, the first time someone is signed in on this
  /// device. A refusal is respected — after that, only a tap the reader
  /// makes themselves ([enable]) asks again.
  Future<void> askOnce() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool(_askedKey) ?? false) return;
    await prefs.setBool(_askedKey, true);
    try {
      await FirebaseMessaging.instance.requestPermission();
    } catch (_) {}
    await refreshPermission();
  }

  /// From an "Enable" / "Turn on" the reader tapped. Shows the system prompt
  /// while Android still offers it; once Android has stopped offering it
  /// (denied twice, or turned off in settings) opens the app's notification
  /// settings instead, since that's the only way back.
  Future<bool> enable() async {
    final started = DateTime.now();
    try {
      await FirebaseMessaging.instance.requestPermission();
    } catch (_) {}
    if (await refreshPermission()) return true;
    // An answer that comes back this fast means no prompt was shown.
    final noPromptShown =
        DateTime.now().difference(started) < const Duration(milliseconds: 500);
    if (noPromptShown) {
      try {
        await _settingsChannel.invokeMethod('openSettings');
      } catch (_) {}
    }
    return false;
  }
}
