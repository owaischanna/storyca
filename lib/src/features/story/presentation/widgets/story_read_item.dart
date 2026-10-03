import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:remixicon/remixicon.dart';
import 'package:storryca/src/core/constants/colors.const.dart';

class StoryReadItem extends StatelessWidget {
  const StoryReadItem({
    super.key,
    required this.chapter,
    required this.title,
    required this.content,
  });

  final String chapter;
  final String title;
  final String content;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        spacing: 8,
        children: [
          ShaderMask(
            shaderCallback: (bounds) {
              return defaultGradientTTB.createShader(bounds);
            },
            child: Icon(Remix.shining_line, size: 16, color: Colors.white),
          ),
          ShaderMask(
            shaderCallback: (bounds) {
              return defaultGradientTTB.createShader(bounds);
            },
            child: Text(
              'CHAPTER $chapter',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, fontSize: 14),
            ),
          ),
          Text(
            title,
            textAlign: TextAlign.center,
            style: GoogleFonts.playfair(fontSize: 18, color: Colors.white),
          ),
          Text(
            content,
            style: GoogleFonts.playfair(
              fontSize: 19,
              color: Colors.white,
              height: 1.6,
            ),
          ),

          // SPACING
          SizedBox(height: 50),
        ],
      ),
    );
  }
}
