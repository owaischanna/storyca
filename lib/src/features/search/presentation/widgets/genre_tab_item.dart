import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:remixicon/remixicon.dart';
import 'package:storryca/src/core/constants/colors.const.dart';

class GenreTabItem extends StatelessWidget {
  const GenreTabItem({
    super.key,
    required this.label,
    required this.description,
    required this.stories,
  });

  final String label;
  final String description;
  final int stories;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Color.fromRGBO(23, 0, 45, 0.7),
        border: Border.all(width: 1, color: Colors.black26),
      ),
      child: Row(
        spacing: 8,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 4,
              children: [
                Text(
                  label,
                  softWrap: true,
                  style: GoogleFonts.playfair(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(color: Color(primaryTextCOLR), fontSize: 12),
                ),
              ],
            ),
          ),
          Row(
            spacing: 4,
            children: [
              Text(
                stories.toString(),
                style: TextStyle(color: Colors.white, fontSize: 12),
              ),
              Icon(Remix.arrow_right_s_line, color: Colors.white, size: 16),
            ],
          ),
        ],
      ),
    );
  }
}
