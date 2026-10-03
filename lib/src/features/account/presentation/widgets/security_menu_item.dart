import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:remixicon/remixicon.dart';
import 'package:storryca/src/core/constants/colors.const.dart';

class SecurityMenuItem extends StatelessWidget {
  const SecurityMenuItem({
    super.key,
    required this.icon,
    required this.title,
    required this.caption,
    required this.route,
    required this.isLast,
  });

  final IconData icon;
  final String title;
  final String caption;
  final String route;
  final bool isLast;

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
              child: Icon(icon, size: 20, color: Color(0xffCF7FFA)),
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
                    caption,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Color(0xff9D8AC5), fontSize: 12),
                  ),
                ],
              ),
            ),
            Icon(Remix.arrow_right_s_line, size: 24, color: Colors.white),
          ],
        ),
      ),
    );
  }
}
