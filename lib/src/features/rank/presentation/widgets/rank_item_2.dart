import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:remixicon/remixicon.dart';
import 'package:storryca/src/core/constants/images.const.dart';
import 'package:storryca/src/core/widgets/app_image.dart';

class RankItem2 extends StatelessWidget {
  const RankItem2({
    super.key,
    required this.id,
    required this.title,
    required this.image,
    required this.reads,
  });

  final int id;
  final String title;
  final String image;
  final double reads;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/story/$id'),
      child: SizedBox(
      width: MediaQuery.of(context).size.width * 0.25,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // TRAY
          Positioned(
            bottom: -52,
            child: Image.asset(
              rankTray2IMG,
              width: MediaQuery.of(context).size.width * 0.25,
              fit: BoxFit.contain,
            ),
          ),
          // STORY
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.25,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0xffFCDFFD), Color(0xff410988)],
                    ),
                  ),
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: AppImage(
                          image,
                          width: MediaQuery.of(context).size.width * 0.19,
                          fit: BoxFit.contain,
                        ),
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width * 0.19,
                        height: MediaQuery.of(context).size.height * 0.12,
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
                        child: Column(
                          spacing: 2,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              title,
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.playfair(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Row(
                              spacing: 2,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Remix.star_fill,
                                  color: Color(0xffC384FF),
                                  size: 10,
                                ),
                                RichText(
                                  text: TextSpan(
                                    children: [
                                      TextSpan(
                                        text: '${reads}K',
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: Color(0xffC384FF),
                                        ),
                                      ),
                                      TextSpan(
                                        text: ' Reads',
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: Color.fromRGBO(
                                            195,
                                            132,
                                            255,
                                            0.7,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 1),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // CROWN
          Positioned(
            top: -32,
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.25,
              child: Center(child: Image.asset(rankCrown2IMG, width: 50)),
            ),
          ),
        ],
      ),
      ),
    );
  }
}
