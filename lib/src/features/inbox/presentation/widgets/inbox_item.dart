import 'package:flutter/material.dart';
import 'package:storryca/src/core/constants/colors.const.dart';
import 'package:storryca/src/core/constants/images.const.dart';
import 'package:storryca/src/core/network/models/notification_api_model.dart';

class InboxItem extends StatelessWidget {
  const InboxItem({super.key, required this.notification, this.onTap});

  final NotificationApiModel notification;

  /// Marks it read and opens what it's about (see Inbox).
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          border: Border.all(width: 1, color: Color.fromRGBO(181, 77, 232, 0.1)),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          spacing: 8,
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: notification.isRead
                    ? Colors.transparent
                    : Color(secondaryCOLR),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            Image.asset(announcementIMG, width: 70),
            Expanded(
              child: Column(
                spacing: 3,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notification.title,
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  if (notification.message.isNotEmpty)
                    Text(
                      notification.message,
                      style: TextStyle(
                        color: Color(primaryTextCOLR),
                        fontSize: 12,
                      ),
                    ),
                  Text(
                    notification.createdAt,
                    style: TextStyle(color: Color(secondaryCOLR), fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
