import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:storryca/src/features/onboarding/presentation/content/onboarding.content.dart';
import 'package:storryca/src/features/onboarding/presentation/widgets/onboarding_screen.dart';

class Onboarding extends StatefulWidget {
  const Onboarding({super.key});

  @override
  State<Onboarding> createState() => _OnboardingState();
}

class _OnboardingState extends State<Onboarding> {
  late PageController _pageController;
  int _pageIndex = 0;

  void nextPage() {
    _pageController.nextPage(
      duration: Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  Future _setNotNewUser() async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'is_new_user';
    prefs.setBool(key, false);
  }

  @override
  void initState() {
    super.initState();

    _pageController = PageController(initialPage: 0);
  }

  @override
  void dispose() {
    super.dispose();

    // SET AS NOT A NEW USER
    _setNotNewUser();

    // RE-SHOW TOP AND BOTTOM SYSTEM UI
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );

    _pageController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView.builder(
        itemCount: onboardingContent.length,
        onPageChanged: (index) {
          setState(() {
            _pageIndex = index;
          });
        },
        controller: _pageController,
        itemBuilder: (context, index) {
          return OnboardingScreen(
            pageIndex: _pageIndex,
            nextPage: nextPage,
            plainTitle: onboardingContent[index].plainTitle,
            highlightTitle: onboardingContent[index].highlightTitle,
            caption: onboardingContent[index].caption,
            image: onboardingContent[index].image,
          );
        },
      ),
    );
  }
}
