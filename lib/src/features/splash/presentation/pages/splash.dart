import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:storryca/src/core/constants/images.const.dart';
import 'package:storryca/src/core/network/api.dart';

class Splash extends StatefulWidget {
  const Splash({super.key});

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    // HIDE TOP AND BOTTOM SYSTEM UI
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

    // SPLASH SCREEN TIMER
    Future.delayed(const Duration(seconds: 1), () async {
      if (!mounted) return;

      // TAKE USER HOME IF RETURNING OR ONBOARDING IF NEW
      final prefs = await SharedPreferences.getInstance();
      if (!mounted) return;

      final key = 'is_new_user';
      final isNewUser = prefs.getBool(key);

      SystemChrome.setEnabledSystemUIMode(
        SystemUiMode.manual,
        overlays: SystemUiOverlay.values,
      );

      SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(
          systemNavigationBarColor: Colors.black,
          systemNavigationBarDividerColor: Colors.black,
          systemNavigationBarIconBrightness: Brightness.light,
          systemNavigationBarContrastEnforced: false,
        ),
      );

      // Opened by tapping a push while the app was closed — go where it
      // points, on top of the main screen so Back still lands somewhere.
      final launchRoute = await pushService.takeLaunchRoute();
      if (!mounted) return;

      if (isNewUser == null) {
        context.go('/onboarding');
      } else {
        context.go('/main/2');
        if (launchRoute != null) context.push(launchRoute);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xffDDE6F5), Color(0xff1D35F6), Color(0xff1C2FCB)],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(logoGlowIMG),
              Text(
                'StorryCa',
                style: GoogleFonts.playfair(
                  color: Colors.white,
                  fontSize: 34,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
