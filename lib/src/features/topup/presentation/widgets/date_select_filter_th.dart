import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:remixicon/remixicon.dart';
import 'package:storryca/src/core/constants/colors.const.dart';

class DateSelectFilterTH extends StatelessWidget {
  const DateSelectFilterTH({
    super.key,
    required this.date,
    required this.type,
    required this.setSheetModal,
    required this.update,
  });

  final String date;
  final String type;
  final void Function(void Function()) setSheetModal;
  final void Function(String) update;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        GestureDetector(
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              firstDate: DateTime(2026, 1, 1),
              lastDate: DateTime.now(),
            );

            setSheetModal(() {
              if (date != null) {
                String formattedDate = DateFormat('MMM d, yyyy').format(date);
                update(formattedDate);
              }
            });
          },
          child: Container(
            constraints: BoxConstraints(minWidth: 150),
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              border: Border.all(width: 1, color: Color(secondaryCOLR)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              spacing: 10,
              children: [
                Icon(
                  Remix.calendar_event_line,
                  color: Color(0xffDFBDFF),
                  size: 16,
                ),
                Text(date, style: TextStyle(color: Colors.white, fontSize: 16)),
              ],
            ),
          ),
        ),
        Positioned(
          top: -6,
          left: 10,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 4),
            color: Color(0xff0E0318),
            child: Text(
              '$type Date',
              style: TextStyle(color: Color(0xffDFBDFF), fontSize: 10),
            ),
          ),
        ),
      ],
    );
  }
}
