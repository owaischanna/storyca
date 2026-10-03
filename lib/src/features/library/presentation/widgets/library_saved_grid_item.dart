import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:remixicon/remixicon.dart';
import 'package:storryca/src/core/widgets/app_image.dart';
import 'package:storryca/src/core/widgets/custom_badge.dart';

class LibrarySavedGridItem extends StatelessWidget {
  const LibrarySavedGridItem({
    super.key,
    required this.id,
    required this.image,
    required this.title,
    required this.category,
    required this.rating,
  });

  final int id;
  final String image;
  final String title;
  final String category;
  final int rating;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/story/$id'),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: AppImage(image, width: double.infinity, fit: BoxFit.cover),
          ),
          Container(
            padding: EdgeInsets.all(4),
            // width: 114,
            // height: 150,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              gradient: LinearGradient(
                colors: [
                  Color.fromRGBO(0, 0, 0, 0),
                  Color.fromRGBO(0, 0, 0, 0.92),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    GestureDetector(
                      onTap: () {},
                      child: Icon(
                        Remix.bookmark_fill,
                        color: Color(0xff2D0079),
                        size: 24,
                      ),
                    ),
                  ],
                ),
                Column(
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.playfair(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                    Row(
                      spacing: 4,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: CustomBadge(
                            label: category,
                            bgColor: Color(0xff0E0319),
                            textColor: Color(0xffC384FF),
                            fontSize: 9,
                          ),
                        ),
                        Row(
                          spacing: 2,
                          children: [
                            ...List.generate(rating, (index) {
                              return Icon(
                                Remix.star_fill,
                                color: Color(0xffF8B231),
                                size: 8,
                              );
                            }),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
