import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:remixicon/remixicon.dart';
import 'package:storryca/src/core/constants/colors.const.dart';
import 'package:storryca/src/core/widgets/app_image.dart';
import 'package:storryca/src/core/widgets/custom_badge.dart';

class HeroSlideItem extends StatelessWidget {
  const HeroSlideItem({
    super.key,
    required this.title,
    required this.caption,
    required this.image,
    required this.id,
    required this.rating,
    required this.badge,
  });

  final String title;
  final String caption;
  final String image;
  final int id;
  final int rating;
  final String badge;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: AppImage(
            image,
            width: MediaQuery.of(context).size.width * 0.8,
            height: MediaQuery.of(context).size.height * 0.24,
            fit: BoxFit.fitWidth,
          ),
        ),
        Container(
          padding: EdgeInsets.all(16),
          width: MediaQuery.of(context).size.width * 0.8,
          height: MediaQuery.of(context).size.height * 0.24,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
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
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: badge.isEmpty
                ? MainAxisAlignment.end
                : MainAxisAlignment.spaceBetween,
            children: [
              if (badge.isNotEmpty) CustomBadge(label: badge),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.playfair(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    caption,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                  SizedBox(height: 8),
                  Row(
                    spacing: 16,
                    children: [
                      GestureDetector(
                        onTap: () => context.push('/story/$id'),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            vertical: 5,
                            horizontal: 10,
                          ),
                          decoration: BoxDecoration(
                            gradient: defaultGradientTTB,
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Text(
                            'Read Now',
                            style: TextStyle(color: Colors.white, fontSize: 12),
                          ),
                        ),
                      ),
                      Row(
                        spacing: 4,
                        children: [
                          ...List.generate(rating, (index) {
                            return Icon(
                              Remix.star_fill,
                              color: Color(0xFFF8B231),
                              size: 16,
                            );
                          }),
                          ...List.generate((5 - rating), (index) {
                            return Icon(
                              Remix.star_fill,
                              color: Color(0xFF818181),
                              size: 16,
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
    );
  }
}
