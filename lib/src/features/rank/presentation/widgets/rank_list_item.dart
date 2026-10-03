import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:remixicon/remixicon.dart';
import 'package:storryca/src/core/widgets/app_image.dart';
import 'package:storryca/src/core/widgets/custom_badge.dart';

class RankListItem extends StatelessWidget {
  const RankListItem({
    super.key,
    required this.id,
    required this.rank,
    required this.image,
    required this.title,
    required this.author,
    required this.category,
    required this.reads,
    required this.rating,
    required this.isSaved,
  });

  final int id;
  final int rank;
  final String image;
  final String title;
  final String author;
  final String category;
  final double reads;
  final int rating;
  final bool isSaved;

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
        spacing: 12,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              spacing: 8,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  rank.toString(),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  width: 0.5,
                  height: 70,
                  color: Color.fromRGBO(195, 132, 255, 0.1),
                ),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: AppImage(image, width: 50, height: 67),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    spacing: 16,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: 16,
                        children: [
                          Column(
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
                                author,
                                style: TextStyle(
                                  color: Color.fromRGBO(195, 132, 255, 0.5),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            spacing: 8,
                            children: [
                              CustomBadge(
                                label: category,
                                textColor: Color(0xffC384FF),
                                bgColor: Color.fromRGBO(195, 132, 255, 0.1),
                              ),
                              Row(
                                spacing: 4,
                                children: [
                                  ShaderMask(
                                    blendMode: BlendMode.srcIn,
                                    shaderCallback: (bounds) {
                                      return LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [
                                          Color(0xffFFE4B1),
                                          Color(0xffF8B231),
                                        ],
                                      ).createShader(bounds);
                                    },
                                    child: Icon(
                                      Remix.fire_fill,
                                      color: Colors.white,
                                      size: 12,
                                    ),
                                  ),
                                  Text(
                                    '${reads.toInt()} Reads',
                                    style: TextStyle(
                                      color: Color(0xffC384FF),
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                spacing: 4,
                                children: [
                                  Icon(
                                    Remix.star_fill,
                                    size: 12,
                                    color: Color(0xffF8B231),
                                  ),
                                  Text(
                                    rating.toString(),
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                    ),
                                  ),
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
          ),
          Icon(
            isSaved ? Remix.bookmark_fill : Remix.bookmark_line,
            color: Color.fromRGBO(195, 132, 255, 0.5),
          ),
        ],
      ),
      ),
    );
  }
}
