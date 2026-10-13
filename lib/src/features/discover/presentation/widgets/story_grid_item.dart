import 'package:flutter/material.dart';
import 'package:storryca/src/core/utils/compact_count.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:remixicon/remixicon.dart';
import 'package:storryca/src/core/widgets/app_image.dart';

class StoryGridItem extends StatelessWidget {
  const StoryGridItem({
    super.key,
    required this.title,
    required this.id,
    required this.image,
    required this.reads,
    required this.chapters,
  });

  final String title;
  final int id;
  final String image;
  final double reads;
  final int chapters;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/story/$id'),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(5),
            child: AppImage(image, width: 50, height: 67),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.playfair(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                // A grid card is narrow (two per row), and "Chapters" runs
                // much wider than a bare number ever did — Wrap lets the
                // chapter count drop to its own line instead of overflowing
                // the card when both bits of text don't fit on one.
                Wrap(
                  spacing: 8,
                  runSpacing: 2,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      '${compactCount(reads)} Reads',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color.fromRGBO(195, 132, 255, 0.5),
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Remix.list_unordered,
                          size: 12,
                          color: Color.fromRGBO(195, 132, 255, 0.5),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '$chapters Chapters',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color.fromRGBO(195, 132, 255, 0.5),
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
    );
  }
}
