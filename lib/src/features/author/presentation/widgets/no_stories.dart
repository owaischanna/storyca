import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:remixicon/remixicon.dart';
import 'package:storryca/src/core/constants/colors.const.dart';
import 'package:storryca/src/core/constants/images.const.dart';
import 'package:storryca/src/core/widgets/gradient_button.dart';

class NoStories extends StatelessWidget {
  const NoStories({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.7,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        spacing: 16,
        children: [
          Image.asset(noStoryIMG, width: 200),
          Column(
            spacing: 8,
            children: [
              Text(
                'You don’t have any stories yet',
                style: GoogleFonts.playfair(color: Colors.white, fontSize: 20),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 50),
                child: Text(
                  textAlign: TextAlign.center,
                  'Every great story starts with a single word. Start writing your first story and share it with the world.',
                  style: TextStyle(color: Color(primaryTextCOLR), fontSize: 12),
                ),
              ),
              SizedBox(
                width: 200,
                height: 40,
                child: GradientButton(
                  label: 'Write My First Story',
                  hasIcon: true,
                  icon: Remix.ball_pen_line,
                  radius: 8,
                  padding: EdgeInsets.all(0),
                  onPressed: () => context.push('/new-story'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
