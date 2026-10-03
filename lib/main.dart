import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:storryca/src/app/router/app_router.dart';
import 'package:storryca/src/core/network/api.dart';
import 'package:storryca/src/core/network/push_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  MobileAds.instance.initialize();
  // Starts listening for Play Billing purchases immediately, not just while
  // the top-up screen is open — a purchase that finishes while the app is
  // backgrounded or was killed mid-purchase is redelivered as soon as this
  // subscribes, which is how it still ends up verified and credited. A
  // no-op on non-Android platforms.
  playBillingService.start();

  final router = createRouter();
  // Not awaited — pushes must never hold up the first frame.
  unawaited(pushService.init(router));

  runApp(MyApp(router: router));
}

class MyApp extends StatefulWidget {
  final GoRouter router;

  const MyApp({super.key, required this.router});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  Timer? _sessionTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    authService.onSessionExpired = () {
      widget.router.go('/signin');
    };
    // getToken() itself signs out once 48 hours have passed; checking every
    // minute (and on resume) makes that happen even while the app sits open.
    _sessionTimer = Timer.periodic(
      const Duration(minutes: 1),
      (_) => authService.getToken(),
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      authService.getToken();
      // Picks up a permission granted in system settings, and retries a
      // push registration that failed while offline.
      pushService.onResume();
    }
  }

  @override
  void dispose() {
    _sessionTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerConfig: widget.router,
    );
  }
}
