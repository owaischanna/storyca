import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:remixicon/remixicon.dart';
import 'package:storryca/src/core/constants/colors.const.dart';
import 'package:storryca/src/core/constants/images.const.dart';
import 'package:storryca/src/core/constants/text_styyle.dart';
import 'package:storryca/src/core/network/models/author_api_model.dart';

class AboutAuthorTab extends StatelessWidget {
  const AboutAuthorTab({super.key, required this.author});

  final AuthorApiModel author;

  String get _joinedLabel {
    final date = DateTime.tryParse(author.joinedAt);
    return date == null ? author.joinedAt : DateFormat('MMM yyyy').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Column(
        spacing: 16,
        children: [
          // ABOUT AUTHOR
          Column(
            children: [
              Row(
                spacing: 8,
                children: [
                  ShaderMask(
                    shaderCallback: (bounds) {
                      return defaultGradientTTB.createShader(bounds);
                    },
                    child: Icon(Remix.leaf_fill, size: 16, color: Colors.white),
                  ),
                  Text(
                    'About ${author.name}',
                    style: GoogleFonts.playfair(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
              Text(author.aboutMe, style: defaultTextStyle),
            ],
          ),

          // ABOUT MY BOOKS — only when the author has written it.
          if (author.aboutMyBooks.trim().isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  spacing: 8,
                  children: [
                    ShaderMask(
                      shaderCallback: (bounds) {
                        return defaultGradientTTB.createShader(bounds);
                      },
                      child: Icon(
                        Remix.book_2_fill,
                        size: 16,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'About My Books',
                      style: GoogleFonts.playfair(
                        color: Colors.white,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
                Text(author.aboutMyBooks, style: defaultTextStyle),
              ],
            ),

          // SEPERATOR
          Row(
            spacing: 8,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Divider(
                  height: 1,
                  color: Color.fromRGBO(157, 138, 197, 0.1),
                ),
              ),
              Icon(
                Remix.shining_2_fill,
                color: Color(primaryTextCOLR),
                size: 6,
              ),
              Expanded(
                child: Divider(
                  height: 1,
                  color: Color.fromRGBO(157, 138, 197, 0.1),
                ),
              ),
            ],
          ),

          // AUTHOR INFO
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                spacing: 4,
                children: [
                  Row(
                    spacing: 4,
                    children: [
                      ShaderMask(
                        shaderCallback: (bounds) {
                          return defaultGradientTTB.createShader(bounds);
                        },
                        child: Icon(
                          Remix.calendar_line,
                          size: 14,
                          color: Colors.white,
                        ),
                      ),
                      Text('Joined', style: defaultTextStyle),
                    ],
                  ),
                  Text(_joinedLabel, style: defaultTextStyle),
                ],
              ),
              SizedBox(
                height: 40,
                child: VerticalDivider(
                  color: Color.fromRGBO(157, 138, 197, 0.1),
                ),
              ),
              Column(
                spacing: 4,
                children: [
                  Row(
                    spacing: 4,
                    children: [
                      ShaderMask(
                        shaderCallback: (bounds) {
                          return defaultGradientTTB.createShader(bounds);
                        },
                        child: Icon(
                          Remix.map_pin_line,
                          size: 14,
                          color: Colors.white,
                        ),
                      ),
                      Text('Location', style: defaultTextStyle),
                    ],
                  ),
                  Text(author.location, style: defaultTextStyle),
                ],
              ),
              SizedBox(
                height: 40,
                child: VerticalDivider(
                  color: Color.fromRGBO(157, 138, 197, 0.1),
                ),
              ),
              Column(
                spacing: 4,
                children: [
                  Row(
                    spacing: 4,
                    children: [
                      ShaderMask(
                        shaderCallback: (bounds) {
                          return defaultGradientTTB.createShader(bounds);
                        },
                        child: Icon(
                          Remix.global_line,
                          size: 14,
                          color: Colors.white,
                        ),
                      ),
                      Text('Language', style: defaultTextStyle),
                    ],
                  ),
                  Text(author.language, style: defaultTextStyle),
                ],
              ),
              SizedBox(
                height: 40,
                child: VerticalDivider(
                  color: Color.fromRGBO(157, 138, 197, 0.1),
                ),
              ),
              Column(
                spacing: 4,
                children: [
                  Row(
                    spacing: 4,
                    children: [
                      ShaderMask(
                        shaderCallback: (bounds) {
                          return defaultGradientTTB.createShader(bounds);
                        },
                        child: Icon(
                          Remix.time_line,
                          size: 14,
                          color: Colors.white,
                        ),
                      ),
                      Text('Active', style: defaultTextStyle),
                    ],
                  ),
                  Text(author.availability, style: defaultTextStyle),
                ],
              ),
            ],
          ),

          // AUTHOR NOTE
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Color.fromRGBO(181, 77, 232, 0.1),
              border: Border.all(
                width: 1,
                color: Color.fromRGBO(181, 77, 232, 0.1),
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              spacing: 8,
              children: [
                Image.asset(readersNoteIMG, width: 40),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 2,
                    children: [
                      Text(
                        'A Note to My Readers',
                        style: GoogleFonts.playfair(
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      ),
                      Text(author.toMyReaders, style: defaultTextStyle),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
