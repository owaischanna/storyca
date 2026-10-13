import 'package:flutter/services.dart';

/// Blocks screenshots / screen recording while a novel chapter is on screen
/// (Android FLAG_SECURE, toggled in MainActivity). Everywhere else in the app
/// stays capturable.
///
/// Counted, not a plain on/off: moving to the next chapter replaces one
/// reader with another, and the new one opens before the old one closes — so
/// protection only lifts once the last open reader has gone.
class SecureScreen {
  static const MethodChannel _channel = MethodChannel('storryca/secure');
  static int _open = 0;

  static void enter() {
    if (_open++ == 0) _invoke('enable');
  }

  static void exit() {
    if (_open == 0) return;
    if (--_open == 0) _invoke('disable');
  }

  static void _invoke(String method) {
    _channel.invokeMethod(method).catchError((_) {
      // Not Android (or no channel) — nothing to toggle.
    });
  }
}
