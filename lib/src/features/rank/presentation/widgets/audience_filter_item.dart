import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';

class AudienceFilterItem extends StatelessWidget {
  const AudienceFilterItem({
    super.key,
    required this.setSheetModal,
    required this.updateAudience,
    required this.selectedAudience,
    required this.item,
  });

  final void Function(void Function()) setSheetModal;
  final void Function(String) updateAudience;
  final String selectedAudience;
  final String item;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setSheetModal(() {
          updateAudience(item);
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        decoration: BoxDecoration(
          color: selectedAudience == item
              ? Color.fromRGBO(153, 79, 255, 0.1)
              : Colors.transparent,
          boxShadow: [
            if (selectedAudience == item)
              BoxShadow(
                color: Color.fromRGBO(145, 16, 222, 0.3),
                blurRadius: 10,
              ),
          ],
          border: Border.all(
            width: 1,
            color: selectedAudience == item
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
                color: selectedAudience == item
                    ? Colors.white
                    : Color(0xffAF91E7),
                size: 12,
              ),
            Text(
              item,
              style: TextStyle(
                color: selectedAudience == item
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
