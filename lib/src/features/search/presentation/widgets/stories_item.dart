import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:remixicon/remixicon.dart';
import 'package:storryca/src/core/constants/colors.const.dart';
import 'package:storryca/src/core/widgets/app_image.dart';
import 'package:storryca/src/core/widgets/custom_badge.dart';

class StoriesItem extends StatelessWidget {
  const StoriesItem({
    super.key,
    required this.id,
    required this.image,
    required this.title,
    required this.category,
    required this.reads,
    required this.description,
    required this.isSaved,
  });

  final int id;
  final String image;
  final String title;
  final String category;
  final double reads;
  final bool isSaved;
  final String description;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/story/$id'),
      child: Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Color.fromRGBO(23, 0, 45, 0.7),
        border: Border.all(width: 1, color: Colors.black26),
      ),
      child: Row(
        spacing: 8,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: AppImage(image, width: 50, height: 67),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              spacing: 4,
              children: [
                Row(
                  spacing: 16,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            softWrap: true,
                            style: GoogleFonts.playfair(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            description,
                            style: TextStyle(
                              color: Color(primaryTextCOLR),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      isSaved ? Remix.bookmark_fill : Remix.bookmark_line,
                      color: Color.fromRGBO(195, 132, 255, 0.5),
                    ),
                  ],
                ),
                Row(
                  spacing: 8,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CustomBadge(
                      label: category,
                      textColor: Color(0xffC384FF),
                      bgColor: Color.fromRGBO(195, 132, 255, 0.1),
                    ),
                    Text(
                      '🔥 ${reads}K',
                      style: TextStyle(color: Color(0xffC384FF), fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
        ),
      ),
    );
  }
}
