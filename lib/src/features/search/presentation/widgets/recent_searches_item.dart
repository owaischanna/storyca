import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';
import 'package:storryca/src/core/constants/colors.const.dart';

class RecentSearchesItem extends StatelessWidget {
  const RecentSearchesItem({
    super.key,
    required this.label,
    required this.isLast,
    required this.onTap,
    required this.onDelete,
  });

  final String label;
  final bool isLast;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(8),
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
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
                spacing: 4,
                children: [
                  Icon(
                    Remix.time_line,
                    size: 16,
                    color: Color(primaryTextCOLR),
                  ),
                  Flexible(
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: onDelete,
              child: Icon(
                Remix.close_large_line,
                size: 14,
                color: Color(primaryTextCOLR),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
