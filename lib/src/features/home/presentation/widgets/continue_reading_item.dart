import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ContinueReadingItem extends StatelessWidget {
  const ContinueReadingItem({
    super.key,
    required this.title,
    required this.image,
    required this.chapter,
    required this.progress,
  });

  final String title;
  final String image;
  final int chapter;
  final double progress;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.asset(image, width: 112, height: 150),
        ),
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            gradient: LinearGradient(
              colors: [
                Color.fromRGBO(0, 0, 0, 0),
                Color.fromRGBO(0, 0, 0, 0.92),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          width: 112,
          height: 150,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "$title - Ch$chapter",
                style: GoogleFonts.playfair(color: Colors.white, fontSize: 14),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    height: 5,
                    width: 70,
                    child: ShaderMask(
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
                  ),
                  Text(
                    '${(progress * 100).round()}%',
                    style: TextStyle(color: Colors.white, fontSize: 10),
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
