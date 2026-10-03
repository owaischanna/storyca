import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';
import 'package:storryca/src/core/constants/colors.const.dart';
import 'package:storryca/src/core/constants/text_styyle.dart';

class ChapterReorderItem extends StatelessWidget {
  const ChapterReorderItem({
    super.key,
    required this.index,
    required this.title,
    required this.words,
    required this.status,
    required this.date,
  });

  final int index;
  final String title;
  final String words;
  final String status;
  final String date;

  @override
  Widget build(BuildContext context) {
    int color = 0XFF9D8AC5;

    if (status == 'Published') {
      color = 0xFF00B076;
    } else if (status == 'In review') {
      color = 0xFFFE682E;
    } else if (status == 'Draft') {
      color = 0xFFB54DE8;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 16),
        decoration: BoxDecoration(
          border: Border.all(width: 1, color: Color.fromRGBO(92, 9, 180, 0.1)),
          borderRadius: BorderRadius.circular(4),
          color: Color.fromRGBO(92, 9, 180, 0.1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
                spacing: 12,
                children: [
                  Icon(
                    Remix.draggable,
                    size: 24,
                    color: Color(primaryTextCOLR),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text('$words words', style: defaultTextStyle10),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Row(
              spacing: 12,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '$status •',
                      style: TextStyle(
                        color: Color(color),
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(date, style: defaultTextStyle10),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
