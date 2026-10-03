import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:remixicon/remixicon.dart';
import 'package:storryca/src/core/constants/colors.const.dart';
import 'package:storryca/src/core/constants/images.const.dart';
import 'package:storryca/src/features/onboarding/presentation/widgets/rect_indicator.dart';

class OnboardingScreen extends StatelessWidget {
  final int pageIndex;
  final void Function() nextPage;
  final String plainTitle;
  final String highlightTitle;
  final String caption;
  final String image;

  const OnboardingScreen({
    super.key,
    required this.pageIndex,
    required this.nextPage,
    required this.plainTitle,
    required this.highlightTitle,
    required this.caption,
    required this.image,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1D0632), Colors.black],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 50.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // INDICATOR
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        spacing: 8,
                        children: [
                          ...List.generate(3, (index) {
                            return RectIndicator(isActive: index <= pageIndex);
                          }),
                        ],
                      ),
                      InkWell(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          if (pageIndex == 2) {
                            context.go('/signin');
                          } else {
                            context.go('/main');
                          }
                        },
                        child: Text(
                          pageIndex == 2 ? 'Login' : 'Skip',
                          style: TextStyle(
                            color: Color(secondaryCOLR),
                            fontSize: 20,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // TTTLE AND IMAGE
                Column(
                  spacing: 32,
                  verticalDirection: pageIndex > 0
                      ? VerticalDirection.up
                      : VerticalDirection.down,
                  children: [
                    // TEXT AND TITLE
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Column(
                        spacing: 16,
                        children: [
                          // HEADER
                          Column(
                            children: [
                              Text(
                                plainTitle,
                                style: GoogleFonts.playfair(
                                  color: Colors.white,
                                  fontSize: 42,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                highlightTitle,
                                style: GoogleFonts.playfair(
                                  fontSize: 42,
                                  fontWeight: FontWeight.bold,
                                  foreground: Paint()
                                    ..shader = defaultGradientLTR.createShader(
                                      Rect.fromLTWH(0, 0, 200, 70),
                                    ),
                                ),
                              ),
                            ],
                          ),

                          // STAR HIGHLIGHTER
                          Image.asset(heroTextHighlighterIMG),

                          // CAPTION
                          Text(
                            caption,
                            style: TextStyle(
                              color: Color(primaryTextCOLR),
                              fontSize: 16,
                              fontWeight: FontWeight.w300,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),

                    // HERO IMAGE
                    Image.asset(
                      image,
                      width: double.infinity,
                      fit: BoxFit.contain,
                    ),
                  ],
                ),
                // BUTTON
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: SizedBox(
                    width: double.infinity,
                    child: InkWell(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        if (pageIndex < 2) {
                          nextPage();
                        } else {
                          context.go('/main');
                        }
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                        decoration: BoxDecoration(
                          gradient: defaultGradientTTB,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Visibility(
                          visible: pageIndex < 2,
                          replacement: Row(
                            spacing: 16,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Get Started',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                              RotatedBox(
                                quarterTurns: 2,
                                child: ShaderMask(
                                  blendMode: BlendMode.srcIn,
                                  shaderCallback: (bounds) => LinearGradient(
                                    begin: Alignment.centerRight,
                                    end: Alignment.centerLeft,
                                    colors: [
                                      Color(0xFFFFFFFF),
                                      Color(0xFFF8B231),
                                    ],
                                  ).createShader(bounds),
                                  child: Icon(
                                    Remix.sparkling_2_fill,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(),
                              Text(
                                'Next',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                              Icon(
                                Remix.arrow_right_long_line,
                                size: 24,
                                color: Colors.white,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
