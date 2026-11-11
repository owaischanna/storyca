import 'package:flutter/material.dart';
import 'package:storryca/src/core/network/api.dart';
import 'package:storryca/src/core/network/api_client.dart';

bool _asking = false;

/// The session token whose answer is already known, so the tab shell can
/// call this on every visit without re-asking the server.
String? _settledFor;

/// The app's side of the website's age check: asks a signed-in reader, once,
/// whether they are 18 or over. Unanswered accounts are treated as under 18
/// by the server, so books rated 18+ stay hidden until they say otherwise.
/// Also keeps `usersRepository.isAdult` current.
///
/// Returns true when the reader has just confirmed they are 18+, so the
/// caller can reload shelves that were hiding 18+ books a moment ago.
Future<bool> askAgeIfNeeded(BuildContext context) async {
  if (_asking) return false;
  final token = await authService.getToken();
  if (token == null) {
    usersRepository.isAdult.value = false;
    return false;
  }
  if (token == _settledFor) return false;
  _asking = true;
  try {
    final status = await usersRepository.ageStatus(token);
    if (status.asked) {
      _settledFor = token;
      return false;
    }
    if (!context.mounted) return false;
    final adult = await showDialog<bool>(
      context: context,
      // Both buttons are an answer; "No" means under 18, not "ask later".
      barrierDismissible: false,
      builder: (context) => const _AgeQuestion(),
    );
    if (adult == null) return false;
    await usersRepository.saveAge(adult, token);
    _settledFor = token;
    return adult;
  } on ApiException {
    // Not recorded — the account is still unanswered, so it is asked again
    // next time rather than left that way for ever.
    return false;
  } finally {
    _asking = false;
  }
}

class _AgeQuestion extends StatelessWidget {
  const _AgeQuestion();

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: AlertDialog(
        backgroundColor: const Color(0xff0E0318),
        title: const Text(
          'One quick question',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Are you 18 years of age or older?\n\n'
          'Books an author has rated 18+ are only shown to readers who are 18 '
          'or over.',
          style: TextStyle(color: Color(0xff9D8AC5)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No, I am under 18'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Yes, I am 18 or older',
              style: TextStyle(color: Color(0xffB54DE8)),
            ),
          ),
        ],
      ),
    );
  }
}
