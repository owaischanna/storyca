import 'package:flutter/material.dart';
import 'package:storryca/src/core/utils/compact_count.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:remixicon/remixicon.dart';
import 'package:storryca/src/core/widgets/app_image.dart';

class LibraryCompletedListItem extends StatelessWidget {
  const LibraryCompletedListItem({
    super.key,
    required this.id,
    required this.currentChapter,
    required this.totalChapter,
    required this.image,
    required this.title,
    required this.progress,
    required this.reads,
    required this.rating,
    required this.ratingCount,
  });

  final int id;
  final int currentChapter;
  final int totalChapter;
  final String image;
  final String title;
  final double progress;
  final double reads;
  final int rating;
  final int ratingCount;

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
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
                spacing: 12,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                          children: [
                            Text(
                              title,
                              style: GoogleFonts.playfair(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              '${compactCount(reads)} Reads',
                              style: TextStyle(
                                color: Color(0xffC384FF),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          spacing: 16,
                          children: [
                            Row(
                              spacing: 4,
                              children: [
                                ...List.generate(rating, (index) {
                                  return Icon(
                                    Remix.star_fill,
                                    color: Color(0xffF8B231),
                                    size: 12,
                                  );
                                }),
                                ...List.generate((5 - rating), (index) {
                                  return Icon(
                                    Remix.star_fill,
                                    color: Color(0xff818181),
                                    size: 12,
                                  );
                                }),
                              ],
                            ),
                            Text(
                              '$ratingCount ratings',
                              style: TextStyle(
                                color: Color(0xffDFBDFF),
                                fontSize: 12,
                              ),
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
                    value: 'rate',
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      spacing: 8,
                      children: [
                        Icon(Remix.star_s_line, color: Colors.white, size: 16),
                        Text(
                          'Rate',
                          style: TextStyle(color: Colors.white, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    height: 40,
                    value: 'mark_as_unread',
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      spacing: 8,
                      children: [
                        Icon(
                          Remix.checkbox_line,
                          color: Color(0xffC23B3B),
                          size: 16,
                        ),
                        Text(
                          'Mark as unread',
                          style: TextStyle(
                            color: Color(0xffC23B3B),
                            fontSize: 14,
                          ),
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
