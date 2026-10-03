import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:remixicon/remixicon.dart';
import 'package:storryca/src/core/constants/colors.const.dart';
import 'package:storryca/src/features/profile/presentation/contents/profile.contents.dart';

class ProfileMenuItem extends StatelessWidget {
  const ProfileMenuItem({
    super.key,
    required this.image,
    required this.title,
    required this.caption,
    required this.route,
    required this.isLast,
    required this.inboxCount,
    required this.isAuthed,
  });

  final String image;
  final String title;
  final String caption;
  final String route;
  final bool isLast;
  final int inboxCount;
  final bool isAuthed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.push(route);
      },
      child: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              width: 1,
              color: isLast
                  ? Colors.transparent
                  : Color.fromRGBO(157, 138, 197, 0.3),
            ),
          ),
        ),
        child: Row(
          spacing: 12,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                border: Border.all(width: 1, color: Color(0xff8343D5)),
                borderRadius: BorderRadius.circular(6),
                gradient: profileIconCardGradientCOLR,
              ),
              child: Image.asset(image, width: 20),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    isAuthed ? authedAuthorCenterCaption : caption,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Color(0xff9D8AC5), fontSize: 12),
                  ),
                ],
              ),
            ),
            if (title.toLowerCase() == 'inbox' && inboxCount > 0)
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: Color(0xff9110DE),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Text(
                    inboxCount.toString(),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            Icon(Remix.arrow_right_s_line, size: 24, color: Colors.white),
          ],
        ),
      ),
    );
  }
}
