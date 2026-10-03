import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';
import 'package:storryca/src/core/constants/images.const.dart';
import 'package:storryca/src/features/profile/presentation/contents/profile.contents.dart';

class ProfileUnAuthedHeader extends StatelessWidget {
  const ProfileUnAuthedHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        spacing: 16,
        children: [
          ClipRRect(
            borderRadius: BorderRadiusGeometry.circular(100),
            child: Image.asset(noAvatarIMG, width: 84, height: 84),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              spacing: 8,
              children: [
                Text(
                  'Visitor',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          width: 1,
                          color: Color.fromRGBO(145, 16, 222, 0.5),
                        ),
                      ),
                      child: Row(
                        spacing: 8,
                        children: [
                          Text(
                            'ID: VST-7X2Q9K',
                            style: TextStyle(
                              color: Color(0xff9D8AC5),
                              fontSize: 14,
                            ),
                          ),
                          Icon(
                            Remix.file_copy_line,
                            color: Color(0xff9D8AC5),
                            size: 16,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Text(
                  visitorHeaderCaption,
                  softWrap: true,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Color(0xff9D8AC5), fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
