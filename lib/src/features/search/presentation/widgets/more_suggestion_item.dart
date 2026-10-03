import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';

class MoreSuggestionItem extends StatelessWidget {
  const MoreSuggestionItem({
    super.key,
    this.item = '',
    this.icon = Remix.question_line,
    this.hasIcon = false,
  });

  final String item;
  final IconData icon;
  final bool hasIcon;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // context.pop('/$item');
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(color: Color.fromRGBO(145, 16, 222, 0.2), blurRadius: 10),
          ],
          border: Border.all(width: 0.5, color: Color(0xff994FFF)),
          borderRadius: BorderRadius.circular(100),
        ),
        child: Row(
          children: [
            if (hasIcon) Icon(icon, size: 16, color: Colors.white),

            if (item.isNotEmpty)
              Text(item, style: TextStyle(color: Colors.white, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
