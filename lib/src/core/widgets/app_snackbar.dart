import 'package:flutter/material.dart';
import 'package:storryca/src/core/constants/colors.const.dart';

class AppSnackbar {
  static void success(BuildContext context, String message) {
    _show(context, message, Colors.green);
  }

  static void error(BuildContext context, String message) {
    _show(context, message, Color(primaryTextCOLR));
  }

  static void warning(BuildContext context, String message) {
    _show(context, message, Colors.orange);
  }

  static void info(BuildContext context, String message) {
    _show(context, message, Colors.blue);
  }

  static void _show(BuildContext context, String message, Color color) {
    final messenger = ScaffoldMessenger.of(context);

    messenger.hideCurrentSnackBar();

    messenger.showSnackBar(
      SnackBar(
        backgroundColor: color,
        content: Text(message),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
