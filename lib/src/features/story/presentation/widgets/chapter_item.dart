import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';
import 'package:storryca/src/core/constants/colors.const.dart';
import 'package:storryca/src/core/constants/text_styyle.dart';

class ChapterItem extends StatelessWidget {
  const ChapterItem({
    super.key,
    required this.index,
    required this.title,
    required this.words,
    required this.status,
    required this.date,
    required this.onEdit,
    required this.onPublish,
    required this.onDelete,
  });

  final int index;
  final String title;
  final String words;
  final String status;
  final String date;
  final VoidCallback onEdit;

  /// Null when the chapter is already published — hides the Publish action.
  final VoidCallback? onPublish;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    int color = 0XFF9D8AC5;

    if (status == 'Published') {
      color = 0xFF00B076;
    } else if (status == 'Draft') {
      color = 0xFFB54DE8;
    }

    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border.all(width: 1, color: Color.fromRGBO(92, 9, 180, 0.1)),
        borderRadius: BorderRadius.circular(4),
        color: Color.fromRGBO(92, 9, 180, 0.1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: GestureDetector(
              onTap: onEdit,
              child: Row(
                spacing: 12,
                children: [
                  Text(
                    index.toString(),
                    style: TextStyle(
                      color: Color(secondaryCOLR),
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
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
              PopupMenuButton(
                icon: Icon(Remix.more_2_line, size: 18, color: Colors.white),
                color: Color.fromRGBO(23, 0, 45, 0.9),
                menuPadding: EdgeInsets.all(0),
                shape: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(width: 0),
                ),
                position: PopupMenuPosition.under,
                onSelected: (value) {
                  if (value == 'publish') onPublish?.call();
                  if (value == 'delete') onDelete();
                },
                itemBuilder: (context) {
                  return [
                    if (onPublish != null)
                      PopupMenuItem(
                        height: 40,
                        value: 'publish',
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          spacing: 8,
                          children: [
                            Icon(Remix.flag_line, color: Colors.white, size: 16),
                            Text(
                              'Publish',
                              style: TextStyle(color: Colors.white, fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                    PopupMenuItem(
                      height: 40,
                      value: 'delete',
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        spacing: 8,
                        children: [
                          Icon(
                            Remix.user_unfollow_line,
                            color: Color(0xffC23B3B),
                            size: 16,
                          ),
                          Text(
                            'Delete',
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
        ],
      ),
    );
  }
}
