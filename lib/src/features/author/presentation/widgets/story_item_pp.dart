import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:remixicon/remixicon.dart';
import 'package:storryca/src/core/constants/colors.const.dart';
import 'package:storryca/src/core/constants/text_styyle.dart';
import 'package:storryca/src/core/widgets/app_image.dart';
import 'package:storryca/src/core/widgets/custom_badge.dart';

class StoryItemPP extends StatelessWidget {
  const StoryItemPP({
    super.key,
    required this.id,
    required this.image,
    required this.title,
    required this.description,
    required this.views,
    required this.likes,
    required this.chapters,
    required this.status,
  });

  final int id;
  final String image;
  final String title;
  final String description;
  final String views;
  final String likes;
  final int chapters;
  final String status;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/story/$id'),
      child: Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border.all(width: 1, color: Color.fromRGBO(181, 77, 232, 0.1)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        spacing: 8,
        children: [
          Expanded(
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
                    spacing: 8,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: 2,
                        children: [
                          Row(
                            spacing: 4,
                            children: [
                              Expanded(
                                child: Text(
                                  title,
                                  softWrap: true,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.playfair(
                                    fontSize: 14,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              if (status == 'Ongoing')
                                CustomBadge(
                                  label: 'Ongoing',
                                  fontSize: 10,
                                  bgColor: Color.fromRGBO(181, 77, 232, 0.2),
                                ),
                              if (status == 'Completed')
                                CustomBadge(
                                  label: 'Completed',
                                  fontSize: 10,
                                  textColor: Color(0xff00B076),
                                  bgColor: Color.fromRGBO(0, 176, 118, 0.2),
                                ),
                            ],
                          ),
                          Text(
                            description,
                            maxLines: 4,
                            overflow: TextOverflow.ellipsis,
                            style: defaultTextStyle,
                          ),
                        ],
                      ),
                      Row(
                        spacing: 8,
                        children: [
                          Row(
                            spacing: 2,
                            children: [
                              Icon(
                                Remix.eye_line,
                                size: 12,
                                color: Color(primaryTextCOLR),
                              ),
                              Text(views, style: defaultTextStyle),
                            ],
                          ),
                          Row(
                            spacing: 2,
                            children: [
                              Icon(
                                Remix.heart_2_line,
                                size: 12,
                                color: Color(primaryTextCOLR),
                              ),
                              Text(likes, style: defaultTextStyle),
                            ],
                          ),
                          Row(
                            spacing: 2,
                            children: [
                              Icon(
                                Remix.list_unordered,
                                size: 12,
                                color: Color(primaryTextCOLR),
                              ),
                              Text(
                                '$chapters Chapters',
                                style: defaultTextStyle,
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
          PopupMenuButton(
            icon: Icon(
              Remix.more_2_line,
              size: 24,
              color: Color.fromRGBO(255, 251, 251, 0.5),
            ),
            color: Color.fromRGBO(23, 0, 45, 0.9),
            menuPadding: EdgeInsets.all(0),
            shape: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(width: 0),
            ),
            position: PopupMenuPosition.under,
            onSelected: (value) {},
            itemBuilder: (context) {
              return [
                PopupMenuItem(
                  height: 40,
                  value: 'add_to_library',
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    spacing: 8,
                    children: [
                      Icon(Remix.bookmark_fill, color: Colors.white, size: 16),
                      Text(
                        'Add to Library',
                        style: TextStyle(color: Colors.white, fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ];
            },
          ),
        ],
      ),
      ),
    );
  }
}
