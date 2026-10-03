import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:remixicon/remixicon.dart';
import 'package:storryca/src/core/constants/colors.const.dart';
import 'package:storryca/src/core/constants/text_styyle.dart';

class StoryChapterItem extends StatelessWidget {
  const StoryChapterItem({
    super.key,
    required this.index,
    required this.name,
    required this.date,
    required this.views,
    required this.isCurrent,
    this.locked = false,
  });

  final int index;
  final String name;
  final String date;
  final String views;
  final bool isCurrent;
  final bool locked;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border.all(width: 1, color: Color.fromRGBO(181, 77, 232, 0.05)),
        borderRadius: BorderRadius.circular(8),
        color: Color.fromRGBO(23, 0, 45, 0.2),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              spacing: 16,
              children: [
                if (isCurrent)
                  ShaderMask(
                    shaderCallback: (bounds) {
                      return defaultGradientTTB.createShader(bounds);
                    },
                    child: Icon(
                      Remix.bar_chart_fill,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                if (!isCurrent) Text(index.toString(), style: whiteF12TS),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Chapter $index',
                        style: GoogleFonts.playfair(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                      Text(name, style: defaultTextStyle),
                      Text(date, style: defaultTextStyle10),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Row(
            spacing: 8,
            children: [
              if (locked)
                Icon(Remix.lock_2_line, color: Color(primaryTextCOLR), size: 16)
              else
                Row(
                  spacing: 4,
                  children: [
                    Text(views, style: defaultTextStyle),
                    Icon(
                      Remix.eye_line,
                      color: Color(primaryTextCOLR),
                      size: 16,
                    ),
                  ],
                ),
              Icon(Remix.arrow_right_s_line, color: Colors.white, size: 16),
            ],
          ),
        ],
      ),
    );
  }
}
