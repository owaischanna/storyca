import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:storryca/src/core/widgets/app_image.dart';

class TrendingCarouselItem extends StatelessWidget {
  const TrendingCarouselItem({
    super.key,
    required this.id,
    required this.title,
    required this.reads,
    required this.image,
  });

  final int id;
  final String title;
  final double reads;
  final String image;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/story/$id'),
      child: SizedBox(
        width: 112,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: AppImage(image, width: 112, height: 150),
            ),
            SizedBox(height: 8),
            Text(
              title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.playfair(color: Colors.white, fontSize: 14),
            ),
            Text(
              '${reads.toInt()} Reads',
              style: TextStyle(
                color: Color.fromRGBO(195, 132, 255, 0.5),
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
