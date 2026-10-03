import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';

class TimeRange extends StatelessWidget {
  const TimeRange({
    super.key,
    required this.setSheetModal,
    required this.updateTimeRange,
    required this.selectedTimeRange,
    required this.item,
  });

  final void Function(void Function()) setSheetModal;
  final void Function(String) updateTimeRange;
  final String selectedTimeRange;
  final String item;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setSheetModal(() {
          updateTimeRange(item);
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        decoration: BoxDecoration(
          color: selectedTimeRange == item
              ? Color.fromRGBO(153, 79, 255, 0.1)
              : Colors.transparent,
          boxShadow: [
            if (selectedTimeRange == item)
              BoxShadow(
                color: Color.fromRGBO(145, 16, 222, 0.3),
                blurRadius: 10,
              ),
          ],
          border: Border.all(
            width: 1,
            color: selectedTimeRange == item
                ? Color(0xff994FFF)
                : Colors.transparent,
          ),
          borderRadius: BorderRadius.circular(100),
        ),
        child: Row(
          spacing: 2,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (item == 'Custom')
              Icon(
                Remix.calendar_event_line,
                color: selectedTimeRange == item
                    ? Colors.white
                    : Color(0xffAF91E7),
                size: 12,
              ),
            Text(
              item,
              style: TextStyle(
                color: selectedTimeRange == item
                    ? Colors.white
                    : Color(0xffAF91E7),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
