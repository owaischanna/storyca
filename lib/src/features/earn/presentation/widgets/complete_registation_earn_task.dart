import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:remixicon/remixicon.dart';
import 'package:storryca/src/core/constants/colors.const.dart';
import 'package:storryca/src/core/constants/images.const.dart';
import 'package:storryca/src/core/constants/text_styyle.dart';

class CompleteRegistationEarnTask extends StatelessWidget {
  const CompleteRegistationEarnTask({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10),

      decoration: BoxDecoration(
        border: Border.all(width: 1, color: Color.fromRGBO(181, 77, 232, 0.3)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 16,
        children: [
          Expanded(
            child: Row(
              spacing: 8,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    border: Border.all(width: 1, color: Color(0xff8343D5)),
                    borderRadius: BorderRadius.circular(6),
                    gradient: profileIconCardGradientCOLR,
                  ),
                  child: Image.asset(userWelcomeIMG, width: 40),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 8,
                    children: [
                      Row(
                        spacing: 4,
                        children: [
                          Expanded(
                            child: Text(
                              'Complete Registration',
                              style: GoogleFonts.playfair(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 3,
                              vertical: 1,
                            ),
                            decoration: BoxDecoration(
                              color: Color.fromRGBO(153, 79, 255, 0.1),
                              border: Border.all(
                                width: 0.1,
                                color: Color(0xFF994FFF),
                              ),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'One Time',
                              style: TextStyle(
                                color: Color(0xFF994FFF),
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Text(
                        'Thank you for joining! Here’s your welcome reward.',
                        style: defaultTextStyle,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Column(
            spacing: 8,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                spacing: 8,
                children: [
                  Image.asset(aCoinIMG, width: 20),
                  Text('+2.0', style: secondaryF16TS),
                ],
              ),
              SizedBox(
                width: 100,
                height: 30,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Color.fromRGBO(0, 255, 170, 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      surfaceTintColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 2,
                      ),
                    ),
                    child: Row(
                      spacing: 8,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Remix.checkbox_circle_line,
                          color: Color(0xFF00FFAA),
                          size: 16,
                        ),
                        Text(
                          'Claimed',
                          style: TextStyle(
                            color: Color(0xFF00FFAA),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
