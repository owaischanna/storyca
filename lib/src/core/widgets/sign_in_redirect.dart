import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:storryca/src/core/network/api_client.dart';

/// Signed out readers tapping Save / Follow / etc. are sent to Sign In
/// rather than shown an error.
void goToSignIn(BuildContext context) => context.push('/signin');

/// True (and already redirected) when [e] is a `not_signed_in` /
/// `session_expired` refusal; false means the caller should show it.
bool redirectIfSignedOut(BuildContext context, ApiException e) {
  if (!e.needsSignIn || !context.mounted) return false;
  goToSignIn(context);
  return true;
}
