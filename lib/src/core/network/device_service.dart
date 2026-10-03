import 'dart:io';
import 'dart:math';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'package:shared_preferences/shared_preferences.dart';

const String _deviceIdKey = 'device_id';

/// A random id generated once on first launch and persisted, so a
/// signed-out reader's view/read counts are attributed to this install
/// rather than counted fresh on every request. Ignored by the server once
/// the reader is signed in — their account is used instead.
class DeviceService {
  String? _cached;

  Future<String> getDeviceId() async {
    final cached = _cached;
    if (cached != null) return cached;

    final prefs = await SharedPreferences.getInstance();
    final existing = prefs.getString(_deviceIdKey);
    if (existing != null) {
      _cached = existing;
      return existing;
    }

    final generated = _generateId();
    await prefs.setString(_deviceIdKey, generated);
    _cached = generated;
    return generated;
  }

  /// A UUID-v4-shaped random id — no need for the `uuid` package just for
  /// this. Satisfies the API's "8-128 chars: letters, numbers, . _ : -".
  String _generateId() {
    final random = Random.secure();
    final bytes = List<int>.generate(16, (_) => random.nextInt(256));
    final hex = bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
    return '${hex.substring(0, 8)}-${hex.substring(8, 12)}-'
        '${hex.substring(12, 16)}-${hex.substring(16, 20)}-'
        '${hex.substring(20)}';
  }
}

/// Builds the `User-Agent` sent on every API call, e.g.
/// `StorrycaApp/1.0.0 (Android 14; Samsung SM-A515F)`, so the server can
/// record the real device/OS for Login Activity and new-device Security
/// Alerts instead of seeing a generic `Dart/x.y` client.
Future<String> buildAppUserAgent() async {
  var version = '1.0.0';
  var os = Platform.operatingSystem;
  var device = Platform.isIOS ? 'iPhone' : 'Android Device';
  // Each lookup is separate so one failing (e.g. package info) can't wipe
  // out the device name.
  try {
    version = (await PackageInfo.fromPlatform()).version;
  } catch (_) {}
  try {
    final info = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      final a = await info.androidInfo;
      os = 'Android ${a.version.release}';
      final brand = a.manufacturer.trim();
      final model = a.model.trim();
      final prefix = brand.isEmpty ||
              model.toLowerCase().startsWith(brand.toLowerCase())
          ? ''
          : '${brand[0].toUpperCase()}${brand.substring(1)} ';
      if (model.isNotEmpty) device = '$prefix$model';
    } else if (Platform.isIOS) {
      final i = await info.iosInfo;
      os = 'iOS ${i.systemVersion}';
      if (i.utsname.machine.isNotEmpty) device = i.utsname.machine;
    }
  } catch (_) {
    // Plugin missing (app not fully rebuilt) — keep the platform defaults.
  }
  String clean(String v) => v.replaceAll(RegExp(r'[();\s]+'), ' ').trim();
  return 'StorrycaApp/$version (${clean(os)}; ${clean(device)})';
}
