import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:remixicon/remixicon.dart';
import 'package:storryca/src/core/constants/colors.const.dart';
import 'package:storryca/src/core/widgets/app_image.dart';

class RecommendedForYouItem extends StatelessWidget {
  const RecommendedForYouItem({
    super.key,
    required this.id,
    required this.image,
    required this.title,
    required this.genre,
    required this.rating,
  });

  final int id;
  final String image;
  final String title;
  final String genre;
  final int rating;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/story/$id'),
      child: SizedBox(
      width: 112,
      child: Column(
        spacing: 8,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 112,
            height: 150,
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadiusGeometry.circular(10),
                  child: AppImage(image, width: 112, height: 150),
                ),
                Container(
                  padding: EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color.fromRGBO(0, 0, 0, 0),
                        Color.fromRGBO(0, 0, 0, 0.7),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 4,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4),
                              color: Color.fromRGBO(14, 3, 25, 0.8),
                              border: Border.all(
                                width: 0.5,
                                color: Color.fromRGBO(195, 132, 255, 0.1),
                              ),
                            ),
                            child: Center(
                              child: Text(
                                genre,
                                softWrap: true,
                                style: TextStyle(
                                  color: Color(secondaryCOLR),
                                  fontSize: 8,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        spacing: 2,
                        children: [
                          ...List.generate(rating, (index) {
                            return Icon(
                              Remix.star_fill,
                              size: 10,
                              color: Color(0xffF8B231),
                            );
                          }),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Text(
            title,
            style: GoogleFonts.playfair(color: Colors.white, fontSize: 12),
          ),
        ],
      ),
      ),
    );
  }
}
