import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:remixicon/remixicon.dart';
import 'package:storryca/src/core/constants/colors.const.dart';
import 'package:storryca/src/core/widgets/app_image.dart';
import 'package:storryca/src/core/widgets/custom_badge.dart';

class AuthorTabAuthorItem extends StatelessWidget {
  const AuthorTabAuthorItem({
    super.key,
    required this.id,
    required this.image,
    required this.name,
    required this.description,
    required this.category,
    required this.stories,
    required this.followers,
    required this.rating,
  });

  final int id;
  final String image;
  final String name;
  final String description;
  final String category;
  final int stories;
  final int followers;
  final double rating;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/author-profile/$id'),
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
          ClipOval(
            child: AppImage(image, width: 60, height: 60, fit: BoxFit.cover),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              spacing: 4,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 4,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            name,
                            softWrap: true,
                            style: GoogleFonts.playfair(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(6),
                            gradient: defaultGradientTTB,
                          ),
                          child: Row(
                            spacing: 4,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Remix.add_large_line,
                                size: 10,
                                color: Colors.white,
                              ),
                              Text(
                                'Follow',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
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
                Row(
                  spacing: 8,
                  children: [
                    CustomBadge(
                      label: category,
                      textColor: Color(0xffC384FF),
                      bgColor: Color.fromRGBO(195, 132, 255, 0.1),
                    ),
                  ],
                ),
                Row(
                  spacing: 8,
                  children: [
                    Row(
                      spacing: 4,
                      children: [
                        Icon(
                          Remix.book_2_fill,
                          size: 10,
                          color: Color(0xff994FFF),
                        ),
                        Text(
                          '$stories Stories',
                          style: TextStyle(
                            color: Color(primaryTextCOLR),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      spacing: 4,
                      children: [
                        Icon(
                          Remix.team_fill,
                          size: 10,
                          color: Color(0xff994FFF),
                        ),
                        Text(
                          '$followers Follwers',
                          style: TextStyle(
                            color: Color(primaryTextCOLR),
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
                          size: 10,
                          color: Color(0xff994FFF),
                        ),
                        Text(
                          '$rating Rating',
                          style: TextStyle(
                            color: Color(primaryTextCOLR),
                            fontSize: 12,
                          ),
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
    );
  }
}
