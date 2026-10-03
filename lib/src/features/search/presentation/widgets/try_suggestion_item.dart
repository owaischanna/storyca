import 'package:flutter/material.dart';
import 'package:storryca/src/core/constants/colors.const.dart';

class TrySuggestionItem extends StatelessWidget {
  const TrySuggestionItem({
    super.key,
    required this.title,
    required this.caption,
    required this.icon,
    required this.isLast,
  });

  final String title;
  final String caption;
  final IconData icon;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            width: 1,
            color: isLast
                ? Colors.transparent
                : Color.fromRGBO(157, 138, 197, 0.2),
          ),
        ),
      ),
      child: Row(
        spacing: 8,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Color(0xff994FFF), size: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(color: Colors.white, fontSize: 16)),
              Text(
                caption,
                style: TextStyle(color: Color(primaryTextCOLR), fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
