import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:remixicon/remixicon.dart';
import 'package:storryca/src/core/constants/colors.const.dart';
import 'package:storryca/src/core/constants/images.const.dart';
import 'package:storryca/src/core/widgets/gradient_button.dart';

class StoryCreated extends StatefulWidget {
  const StoryCreated({super.key, required this.storyId, this.submitted = false});

  final int storyId;

  /// True when the story was submitted for review (status=published), false
  /// when it was only saved as a draft — the copy below reflects which one.
  final bool submitted;

  @override
  State<StoryCreated> createState() => _StoryCreatedState();
}

class _StoryCreatedState extends State<StoryCreated> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF020004),
      body: Container(
        decoration: BoxDecoration(gradient: pageGradientCOLR),
        child: SingleChildScrollView(
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                spacing: 16,
                children: [
                  // HERO
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.5,
                    width: double.infinity,
                    child: Column(
                      spacing: 16,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(storyCreatedIMG, width: 200),
                        Text(
                          widget.submitted
                              ? 'Your story was submitted!'
                              : 'Your story has been created!',
                          style: GoogleFonts.playfair(
                            color: Colors.white,
                            fontSize: 20,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 40),
                          child: Text(
                            widget.submitted
                                ? 'It will go live once an admin reviews and approves it. You can still add or edit chapters while you wait.'
                                : 'Your story is saved as a draft. You can add chapters and submit it for review when you’re ready.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ACTIONS
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(
                        width: 0.5,
                        color: Color.fromRGBO(92, 9, 180, 0.5),
                      ),
                      borderRadius: BorderRadius.circular(12),
                      color: Color.fromRGBO(92, 9, 180, 0.1),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 16,
                      children: [
                        Text(
                          'What’s Next?',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        StoryCreatedNextItem(
                          icon: Remix.booklet_line,
                          title: 'Add Chapters',
                          caption: 'Start adding chapters to build your story.',
                          route: '/chapters/${widget.storyId}',
                        ),
                      ],
                    ),
                  ),

                  // BUTTON
                  SizedBox(
                    height: 40,
                    child: GradientButton(
                      label: 'Go to My Stories',
                      radius: 6,
                      hasIcon: true,
                      icon: Remix.arrow_right_s_line,
                      padding: EdgeInsets.all(0),
                      reverse: true,
                      fontSize: 12,
                      iconSize: 14,
                      onPressed: () => context.pop(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class StoryCreatedNextItem extends StatelessWidget {
  const StoryCreatedNextItem({
    super.key,
    required this.icon,
    required this.title,
    required this.caption,
    required this.route,
  });

  final IconData icon;
  final String title;
  final String caption;
  final String route;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.pushReplacement(route),
      child: Row(
        children: [
          Expanded(
            child: Row(
              spacing: 16,
              children: [
                Container(
                  width: 33,
                  height: 33,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(33),
                    color: Color.fromRGBO(92, 9, 180, 0.1),
                  ),
                  child: ShaderMask(
                    shaderCallback: (bounds) {
                      return defaultGradientTTB.createShader(bounds);
                    },
                    child: Icon(icon, color: Colors.white, size: 18),
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        caption,
                        style: TextStyle(color: Colors.white70, fontSize: 10),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Icon(Remix.arrow_right_s_line, color: Colors.white, size: 16),
        ],
      ),
    );
  }
}
