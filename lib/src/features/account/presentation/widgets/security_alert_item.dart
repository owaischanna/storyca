import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';
import 'package:storryca/src/core/constants/colors.const.dart';

class SecurityAlertItem extends StatelessWidget {
  const SecurityAlertItem({
    super.key,
    required this.type,
    required this.title,
    required this.message,
    required this.location,
    required this.date,
    required this.isLast,
    required this.isRead,
    required this.onTap,
  });

  final String type;
  final String title;
  final String message;
  final String location;
  final String date;
  final bool isLast;
  final bool isRead;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    IconData icon = Remix.question_line;

    if (type == 'computer') {
      icon = Remix.computer_line;
    } else if (type == 'mobile') {
      icon = Remix.smartphone_line;
    } else if (type == 'password' || type == '2fa') {
      icon = Remix.lock_fill;
    } else if (type == 'email') {
      icon = Remix.mail_line;
    }

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
        spacing: 16,
        children: [
          if (!isRead)
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: Color(secondaryCOLR),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          Expanded(
            child: Row(
              spacing: 8,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    border: Border.all(
                      width: 1,
                      color: Color.fromRGBO(131, 67, 213, 0.3),
                    ),
                    borderRadius: BorderRadius.circular(6),
                    gradient: profileIconCardGradientCOLR,
                  ),
                  child: Icon(icon, size: 22, color: Color(0xffCF7FFA)),
                ),
                Expanded(
                  child: Column(
                    spacing: 2,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                      if (location.isNotEmpty)
                        Text(
                          location,
                          style: TextStyle(
                            color: Color(primaryTextCOLR),
                            fontSize: 12,
                          ),
                        ),
                      Text(
                        message,
                        style: TextStyle(
                          color: Color(primaryTextCOLR),
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        date,
                        style: TextStyle(
                          color: Color(primaryTextCOLR),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
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
