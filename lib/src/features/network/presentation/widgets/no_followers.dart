import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:storryca/src/core/constants/colors.const.dart';
import 'package:storryca/src/core/constants/images.const.dart';

class NoFollowers extends StatelessWidget {
  const NoFollowers({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.5,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        spacing: 16,
        children: [
          Image.asset(noFollowersIMG, width: 150),
          Column(
            children: [
              Text(
                'No Followers yet',
                style: GoogleFonts.playfair(color: Colors.white, fontSize: 20),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 50),
                child: Text(
                  textAlign: TextAlign.center,
                  'No one’s following you yet, but your story is just getting started.',
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
