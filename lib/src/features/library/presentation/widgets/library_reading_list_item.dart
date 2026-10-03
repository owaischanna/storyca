import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:storryca/src/core/widgets/app_image.dart';

class LibraryReadingListItem extends StatelessWidget {
  const LibraryReadingListItem({
    super.key,
    required this.id,
    required this.currentChapter,
    required this.totalChapter,
    required this.image,
    required this.title,
    required this.progress,
    this.progressChapterId,
  });

  final int id;
  final int currentChapter;
  final int totalChapter;
  final String image;
  final String title;
  final double progress;

  /// Where to resume reading. Falls back to the story detail page when the
  /// backend hasn't recorded a chapter to resume at.
  final int? progressChapterId;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => progressChapterId != null
          ? context.push('/read/$progressChapterId')
          : context.push('/story/$id'),
      child: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Color.fromRGBO(23, 0, 45, 0.7),
          border: Border.all(width: 1, color: Colors.black26),
        ),
        child: Row(
          spacing: 12,
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
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.playfair(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        'Chapter $currentChapter of $totalChapter',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Color(0xffC384FF),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  ShaderMask(
                    shaderCallback: (bounds) {
                      return const LinearGradient(
                        colors: [
                          Color(0xff8842FF),
                          Color.fromRGBO(255, 255, 255, 0.5),
                        ],
                      ).createShader(bounds);
                    },
                    child: LinearProgressIndicator(
                      borderRadius: BorderRadius.circular(5),
                      value: progress,
                      backgroundColor: Color.fromRGBO(217, 217, 217, 0.1),
                      valueColor: AlwaysStoppedAnimation(Colors.white),
                    ),
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
