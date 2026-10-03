import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:storryca/src/core/constants/colors.const.dart';
import 'package:storryca/src/core/constants/images.const.dart';

class NoStoryReview extends StatelessWidget {
  const NoStoryReview({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.5,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(noReviewIMG, width: 150),
          Column(
            children: [
              Text(
                'No reviews yet',
                style: GoogleFonts.playfair(color: Colors.white, fontSize: 20),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 50),
                child: Text(
                  textAlign: TextAlign.center,
                  'This Story doesn\'t have any reviews yet. Be the first to spark the flame.',
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
