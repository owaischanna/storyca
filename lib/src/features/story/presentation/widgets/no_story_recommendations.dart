import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:storryca/src/core/constants/colors.const.dart';
import 'package:storryca/src/core/constants/images.const.dart';

class NoStoryRecommendations extends StatelessWidget {
  const NoStoryRecommendations({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.5,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(noStoriesAuthorIMG, width: 150),
          Column(
            children: [
              Text(
                'No story recommendations yet',
                style: GoogleFonts.playfair(color: Colors.white, fontSize: 20),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 50),
                child: Text(
                  textAlign: TextAlign.center,
                  'There are no story recommendations similar to this story yet. Stay tuned - amazing stories are on the way!',
                  style: TextStyle(color: Color(primaryTextCOLR), fontSize: 12),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
